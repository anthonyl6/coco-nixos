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

      userSettings = builtins.fromJSON (builtins.readFile ./settings.json);

      userKeymaps = [
        {
          context = "Workspace";
          bindings = { };
        }
        {
          context = "Editor && !menu && !edit_prediction";
          bindings = {
            "shift-alt-f" = "editor::Format";
            "alt-cmd-up" = "editor::AddSelectionAbove";
            "alt-cmd-down" = "editor::AddSelectionBelow";
            "shift-alt-up" = "editor::DuplicateLineUp";
            "shift-alt-down" = "editor::DuplicateLineDown";
          };
        }
        {
          context = "Editor && !menu && edit_prediction";
          bindings = {
            "end" = "editor::AcceptNextWordEditPrediction";
          };
        }
        {
          context = "ProjectPanel && not_editing";
          bindings = {
            "enter" = "project_panel::Rename";
          };
        }
        {
          context = "(VimControl && !menu)";
          bindings = {
            "space" = null;
          };
        }
      ];
    };

    # export zedPackage for other modules
    home.zedPackage = zedPackage;
  };
}
