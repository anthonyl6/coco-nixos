{ pkgs-fresh, ... }:
let
  nix-flatpak = pkgs-fresh.fetchFromGitHub {
    owner = "gmodena";
    repo = "nix-flatpak";
    rev = "v0.7.0";
    hash = "sha256-7ZCulYUD9RmJIDULTRkGLSW1faMpDlPKcbWJLYHoXcs=";
  };
in
{
  imports = [
    "${nix-flatpak}/modules/nixos.nix"
  ];

  services.flatpak = {
    enable = true;
    packages = [
      "com.stremio.Stremio"
    ];
  };
}
