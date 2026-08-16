{pkgs, inputs, ...}: let
  yarg = pkgs.callPackage ../../../../pkgs/yarg.nix {
    yarg-src = inputs.yarg-src;
  };
in {
  home.packages = with pkgs; [
    clonehero
    hidapi
    yarg
  ];
}
