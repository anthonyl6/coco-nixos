{pkgs-fresh, ...}: {
  home.packages = with pkgs-fresh; [
    yarg
    hidapi
  ];
}
