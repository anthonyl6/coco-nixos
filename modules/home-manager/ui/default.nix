{
  pkgs-stable,
  ...
}:
{
  imports = [
    ./niri.nix
    ./dms.nix
  ];

  home.packages = with pkgs-stable; [
    cava
    playerctl
    brightnessctl
    wf-recorder
    slurp
    hyprpicker
    wl-clipboard
    pavucontrol
    pulseaudioFull
    alsa-utils
  ];
}
