{
  pkgs-stable,
  ...
}:

{
  home.packages = with pkgs-stable; [
    xfce.thunar

    # Core plugins
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.thunar-media-tags-plugin

    # Backends / integration (important outside full XFCE)
    gvfs
    udisks
    tumbler

    # Optional helpers
    file-roller # archive support backend
    ffmpegthumbnailer # video thumbnails
  ];

  # File manager default
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = [ "thunar.desktop" ];
  };

  # Required services (Home Manager side)
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Environment fixes for Wayland + portals
  home.sessionVariables = {
    GTK_USE_PORTAL = "1";
  };
}
