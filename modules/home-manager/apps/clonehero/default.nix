{pkgs, ...}: {
  home.packages = with pkgs; [
    clonehero
    hidapi
    (callPackage ../../../../pkgs/yarg.nix {})
  ];
}
