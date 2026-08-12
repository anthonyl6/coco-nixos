{pkgs, ...}:
let
  yarc-launcher = pkgs.callPackage ../../../../pkgs/yarc-launcher.nix {};
in
{
  home.packages = [
    yarc-launcher
    pkgs.hidapi
  ];
}
