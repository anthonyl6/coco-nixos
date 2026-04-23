{
  inputs,
  pkgs-stable,
  lib,
  ...
}:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
    base16Scheme = ./themes/poimandres.yaml;
    polarity = "dark";
    cursor = {
      package = pkgs-stable.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 16;
    };
    targets.qt = {
      enable = true;
      platform = lib.mkForce "qtct";
    };
  };
}
