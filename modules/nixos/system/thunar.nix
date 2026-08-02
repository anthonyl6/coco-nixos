{ pkgs-stable, ... }:
{

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Thumbnail service
  services.tumbler.enable = true;

  environment.systemPackages = with pkgs-stable; [
    # File manager
    thunar

    # Plugins
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin

    gvfs

    file-roller
    ffmpegthumbnailer
  ];
}
