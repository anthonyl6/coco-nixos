{ pkgs-stable, ... }:
{

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Thumbnail service
  services.tumbler.enable = true;

  # D-Bus is required for basically everything here
  services.dbus.enable = true;

  # Wayland portals (critical for Niri)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs-stable; [
      xdg-desktop-portal-gtk
    ];
  };

  # Optional but often needed for network mounts (smb, etc.)
  environment.systemPackages = with pkgs-stable; [
    gvfs
  ];
}
