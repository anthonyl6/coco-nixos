{
  pkgs,
  pkgs-stable,
  ...
}:

let
  tuigreet = "${pkgs-stable.tuigreet}/bin/tuigreet";
  niri-session = "${pkgs.niri}/share/wayland-sessions";
in
{

  programs.niri = {
    enable = true;
    package = pkgs.niri;
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

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
  };
}
