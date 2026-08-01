{ username, lib, ... }:
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
      executable = true;
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

  # Copy config-nix.kdl → config.kdl only when the Nix source changes,
  # so DMS writes to config.kdl survive across switches.
  home.activation.copyNiriConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    config_dest="$HOME/.config/niri/config.kdl"
    config_src="$HOME/.config/niri/config-nix.kdl"
    marker="$HOME/.config/niri/.nix-gen"

    nix_gen=$(readlink "$config_src")
    prev_gen=$(cat "$marker" 2>/dev/null || echo "")

    if [ ! -f "$config_dest" ] || [ "$nix_gen" != "$prev_gen" ]; then
      $DRY_RUN_CMD cp "$config_src" "$config_dest"
      [ -n "$DRY_RUN_CMD" ] || printf '%s' "$nix_gen" > "$marker"
    fi
  '';

  programs.home-manager.enable = true;
}
