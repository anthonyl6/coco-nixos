{ username, ... }:
{
  imports = [
    ./shell
    ./ssh
    ./terminal
    ./ui
    ./apps
    ./dev
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;

  gtk.gtk4.theme = null;

  home.file = {
    ".config/atuin" = {
      force = true;
      source = ../../cfg/atuin;
      recursive = true;
    };
    ".config/btop" = {
      force = true;
      source = ../../cfg/btop;
      recursive = true;
    };
    ".config/commie" = {
      force = true;
      source = ../../cfg/commie;
      recursive = true;
    };
    ".config/direnv" = {
      force = true;
      source = ../../cfg/direnv;
      recursive = true;
    };
    ".config/fastfetch" = {
      force = true;
      source = ../../cfg/fastfetch;
      recursive = true;
    };

    ".config/niri/delayed" = {
      force = true;
      source = ../../cfg/niri/delayed;
    };
    ".config/zed/themes" = {
      force = true;
      source = ../../cfg/zed/themes;
      recursive = true;
    };
    ".config/zed/keymap.json" = {
      force = true;
      source = ../../cfg/zed/keymap.json;
    };
    ".face" = {
      force = true;
      source = ../../.face;
    };
  };

  # home.activation = {
  #   linkNiriSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
  #     #!/usr/bin/env bash
  #     mkdir -p ~/.config/niri
  #     cp -L ~/.config/niri/config-original.kdl ~/.config/niri/config.kdl
  #   '';
  # };

  programs.home-manager.enable = true;
}
