{
  lib,
  pkgs,
  pkgs-fresh,
  ...
}:

let
  extensionDependencies = with pkgs-fresh; [
    openssl
    zlib
  ];

  zedPackage = pkgs.zed-editor; # 👈 use nixpkgs version

in
{
  imports = [
    ./language-servers.nix
  ];

  options.home.zedPackage = lib.mkOption {
    type = lib.types.package;
    description = "The Zed editor package from nixpkgs";
  };

  config = {
    home.packages = extensionDependencies;

    programs.zed-editor = {
      enable = true;
      package = zedPackage;

      extensions = [
        "catppuccin-icons"
        "ghostty"
        "html"
        "java"
        "nix"
        "prisma"
        "sql"
        "toml"
      ];
    };

    # export zedPackage for other modules
    home.zedPackage = zedPackage;

    home.activation.linkZedSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      mkdir -p ~/.config/zed
    '';

    home.file.".config/zed/settings-original.json" = {
      source = ./settings.json;
      force = true;
    };
  };
}
