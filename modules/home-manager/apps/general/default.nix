{
  inputs,
  pkgs-stable,
  pkgs-fresh,
  ...
}:

let
  jetbrainsApps = with pkgs-stable.jetbrains; [
    datagrip
    rider
    rust-rover
    idea
  ];

  vesktopVpn = pkgs-fresh.writeShellScriptBin "vesktop-vpn" ''
    exec ${pkgs-stable.iproute2}/bin/ip netns exec vpn-bypass \
      ${pkgs-fresh.util-linux}/bin/setpriv \
        --reuid=$(id -u) \
        --regid=$(id -g) \
        --init-groups \
      env \
        HOME="$HOME" \
        XDG_CONFIG_HOME="$HOME/.config" \
        XDG_DATA_HOME="$HOME/.local/share" \
        XDG_CACHE_HOME="$HOME/.cache" \
        XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
        XDG_CURRENT_DESKTOP="$XDG_CURRENT_DESKTOP" \
        DISPLAY="$DISPLAY" \
      ${pkgs-fresh.vesktop}/bin/vesktop "$@"
  '';

  vesktopVpnDesktop = {
    "applications/vesktop-vpn.desktop".text = ''
      [Desktop Entry]
      Name=Vesktop (VPN)
      Comment=Run Vesktop inside vpn-bypass namespace
      Exec=vesktop-vpn %U
      Icon=vesktop
      Type=Application
      Categories=Network;Chat;
      Terminal=false
      StartupNotify=true
    '';
  };

in
{

  imports = [
    inputs.zen-browser.homeModules.twilight
    ../editor
    ../helix
  ];

  home.packages =
    with pkgs-fresh;
    [
      spotify
      obsidian
      fontforge
      vesktop
      whatsapp-electron
      zoom-us
      nautilus
      slack
      gimp
      protonmail-desktop
      parsec-bin
      ryubing
      vlc
      yaak
      filezilla
      protonvpn-gui
    ]
    ++ jetbrainsApps
    ++ [
      vesktopVpn
      pkgs-stable.iproute2
    ];

  xdg.dataFile = vesktopVpnDesktop;

  systemd.user.services.protonvpn-gui = {
    Unit.Description = "ProtonVPN GUI";
    Service = {
      ExecStart = "${pkgs-fresh.protonvpn-gui}/bin/protonvpn-app";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.zsh.enable = true;

  programs.zen-browser = {
    enable = true;

    profiles."default" = {
      containersForce = true;
      spacesForce = true;
      pinsForce = true;
      keyboardShortcutsVersion = 16;
    };
  };

  stylix.targets.zen-browser.profileNames = [ "default" ];
}
