{pkgs, ...}: {
  home.packages = with pkgs; [
    clonehero
    hidapi
    (callPackage ../../../../pkgs/yarg.nix {})
    (callPackage ../../../../pkgs/clone-hero-chart-manager.nix {})
  ];
}
