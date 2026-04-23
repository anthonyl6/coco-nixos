{
  inputs,
  stdenv,
  pkgs-stable,
  ...
}:
{
  imports = [
    ./ghostty.nix
  ];

  home.packages = with pkgs-stable; [
    (btop.override {
      rocmSupport = true;
    })
    atuin
    lazygit
    pokeget-rs
    fastfetch
    fzf
    ripgrep
    bat
    gh
    nix-output-monitor
    libnotify
    psmisc
    inputs.ghostty.packages."${stdenv.hostPlatform.system}".default
  ];
}
