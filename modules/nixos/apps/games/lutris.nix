{ config, pkgs-stable, ... }:

{
  environment.systemPackages = with pkgs-stable; [
    lutris
    wineWow64Packages.staging
    winetricks
    protontricks
    zenity
  ];
}
