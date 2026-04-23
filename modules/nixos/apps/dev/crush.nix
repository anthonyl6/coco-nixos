{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    crush
  ];
  nixpkgs.config.allowUnfree = true;
}
