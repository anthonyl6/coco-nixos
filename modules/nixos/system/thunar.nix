{ pkgs-stable, ... }:
{

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Thumbnail service
  services.tumbler.enable = true;

  environment.systemPackages = with pkgs-stable; [
    # File manager
    xfce.thunar

    # Plugins
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.thunar-media-tags-plugin

    gvfs

    file-roller
    ffmpegthumbnailer
  ];
}
