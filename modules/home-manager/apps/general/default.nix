{
  inputs,
  pkgs,
  pkgs-stable,
  pkgs-fresh,
  ...
}: let
  proton-drive-cli = pkgs.callPackage ../../../../pkgs/proton-drive-cli.nix {};

  jetbrainsApps = with pkgs-stable.jetbrains; [
    datagrip
    rider
    rust-rover
    idea
  ];

  # Discord 1.x's native media engine (discord_voice) probes hardware encoders
  # by dlopening libnvidia-encode/libcuda, which it finds because the nixpkgs
  # wrapper puts /run/opengl-driver/lib on LD_LIBRARY_PATH. On this machine
  # (AMD iGPU + NVIDIA eGPU) the NVENC H265 Go Live path crashes the renderer
  # with SIGTRAP on the FrameScorer thread, every time a stream starts.
  # Shadow the NVENC sonames with unloadable stub files so the probe fails and
  # Discord falls back to VA-API on the AMD iGPU (verified: h264 + av1).
  nvencStubs = pkgs-fresh.runCommand "discord-nvenc-soname-stubs" {} ''
    mkdir -p $out/lib
    for lib in libnvidia-encode.so libnvidia-encode.so.1 libcuda.so libcuda.so.1; do
      : > $out/lib/$lib
    done
  '';

  discordNoNvenc = pkgs-fresh.discord.override {
    unwrappedDiscord = pkgs-fresh.discord.unwrappedDiscord.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        sed -i "s|^LD_LIBRARY_PATH='\([^']*/run/opengl-driver/lib\)'\$LD_LIBRARY_PATH|LD_LIBRARY_PATH='${nvencStubs}/lib:\1'\$LD_LIBRARY_PATH|" "$out/opt/Discord/Discord"
        grep -q '${nvencStubs}/lib' "$out/opt/Discord/Discord" || {
          echo 'ERROR: failed to patch Discord wrapper to shadow NVENC' >&2
          exit 1
        }
        # Discord's image-quality measurement (FrameScorer + libvmaf) needs
        # recon frames from the stream encoder. Both the NVENC and VA-API
        # paths fail to provide them and the scorer CHECK-crashes the
        # renderer (SIGTRAP) shortly after a viewer joins / reconfigure.
        # Stop declaring the feature on Linux so the pipeline never spins up.
        js="$out/opt/Discord/modules/discord_voice/index.js"
        sed -i "s|features.declareSupported('image_quality_measurement');|/* patched out: FrameScorer CHECK-crashes Linux streams */|g" "$js"
        if grep -q "image_quality_measurement" "$js"; then
          echo 'ERROR: failed to patch image_quality_measurement in discord_voice' >&2
          exit 1
        fi
      '';
    });
  };

  discordVpn = pkgs-fresh.writeShellScriptBin "discord-vpn" ''
    exec sudo ${pkgs-stable.iproute2}/bin/ip netns exec vpn-bypass \
      ${pkgs-fresh.util-linux}/bin/setpriv \
        --reuid=$(${pkgs-fresh.coreutils}/bin/id -u) \
        --regid=$(${pkgs-fresh.coreutils}/bin/id -g) \
        --init-groups \
      ${pkgs-fresh.coreutils}/bin/env \
        HOME="$HOME" \
        XDG_CONFIG_HOME="$HOME/.config" \
        XDG_DATA_HOME="$HOME/.local/share" \
        XDG_CACHE_HOME="$HOME/.cache" \
        XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
        XDG_CURRENT_DESKTOP="$XDG_CURRENT_DESKTOP" \
        DISPLAY="$DISPLAY" \
      ${discordNoNvenc}/bin/discord "$@"
  '';

  discordVpnDesktop = {
    "applications/discord-vpn.desktop".text = ''
      [Desktop Entry]
      Name=Discord (VPN)
      Comment=Run discord inside vpn-bypass namespace
      Exec=discord-vpn %U
      Icon=discord
      Type=Application
      Categories=Network;Chat;
      Terminal=false
      StartupNotify=true
    '';
  };
in {
  imports = [
    inputs.zen-browser.homeModules.twilight
    ../editor
    ../helix
  ];

  home.packages = with pkgs-fresh;
    [
      spotify
      obsidian
      fontforge
      nautilus
      slack
      gimp
      protonmail-desktop
      parsec-bin
      ryubing
      vlc
      yaak
      filezilla
      proton-vpn
      remmina
    ]
    ++ jetbrainsApps
    ++ [proton-drive-cli]
    ++ [
      discordVpn
      pkgs-stable.iproute2
    ];

  xdg.dataFile = discordVpnDesktop;

  systemd.user.services.proton-vpn = {
    Unit.Description = "ProtonVPN GUI";
    Service = {
      ExecStart = "${pkgs-fresh.proton-vpn}/bin/protonvpn-app";
      Restart = "on-failure";
    };
    Install.WantedBy = ["default.target"];
  };

  programs.zsh.enable = true;

  programs.zen-browser = {
    enable = true;

    profiles."default" = {
      containersForce = true;
      spacesForce = true;
      pinsForce = true;
      keyboardShortcutsVersion = 16;

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        proton-pass
        privacy-badger
      ];

      settings = {
        "extensions.autoDisableScopes" = 0;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
      };
    };
  };

  stylix.targets.zen-browser.profileNames = ["default"];
}
