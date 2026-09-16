{
  inputs,
  stdenv,
  pkgs-stable,
  lib,
  hostname,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
    ./niri.nix
    ./noctalia.nix
    ./vicinae.nix
  ];

  home.packages =
    with pkgs-stable;
    [
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

  # Automatically disable the laptop panel when the external monitor is connected
  # and re-enable it when disconnected.
  services.kanshi = lib.mkIf (hostname == "gabagool") {
    enable = true;
    settings = [
      {
        profile = {
          name = "undocked";
          outputs = [
            {
              criteria = "BOE NE135A1M-NY1";
              status = "enable";
              mode = "2880x1920@120";
              scale = 2.0;
              position = "0,0";
            }
          ];
        };
      }
      {
        profile = {
          name = "docked";
          outputs = [
            {
              criteria = "LG Electronics LG ULTRAWIDE";
              status = "enable";
              mode = "2560x1080@75";
              position = "0,0";
            }
            {
              criteria = "BOE NE135A1M-NY1";
              status = "disable";
            }
          ];
        };
      }
    ];
  };
}
