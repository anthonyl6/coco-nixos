{
  pkgs,
  pkgs-stable,
  inputs,
  ...
}:

let
  tuigreet = "${pkgs-stable.tuigreet}/bin/tuigreet";
  niri-pkg = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri;
  niri-session = "${niri-pkg}/share/wayland-sessions";
in
{

  programs.niri = {
    enable = true;
    package = niri-pkg;
  };

  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          "${tuigreet} " + "--time " + "--remember " + "--remember-session " + "--sessions ${niri-session}";
        user = "greeter";
      };
    };
  };

  # greetd owns the active Wayland session. By default NixOS restarts any
  # systemd service whose unit file changed during a switch; rebuilding with a
  # new niri/tuigreet path (or any unit change) therefore restarts greetd,
  # which tears down the whole user session — every window closes and niri
  # relaunches. greetd can happily keep running the old unit until reboot, so
  # opt out of the restart-on-activation behaviour.
  systemd.services.greetd.restartIfChanged = false;

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  environment.systemPackages = with pkgs-stable; [
    xwayland-satellite
  ];

  # Noctalia desktop shell (v5.1.0 flake) + Vicinae launcher (adds the
  # cap_dac_override-wrapped input server for clipboard/emoji pasting/snippets).
  imports = [
    inputs.noctalia.nixosModules.default
    (inputs.vicinae.nixosModules.default)
  ];

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    systemd = {
      enable = true;
      target = "niri.service";
    };

    recommendedServices.enable = true;
  };
}
