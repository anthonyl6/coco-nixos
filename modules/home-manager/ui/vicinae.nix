{
  inputs,
  lib,
  ...
}:
{
  # Vicinae launcher via upstream home-manager module.
  # Reference: https://docs.vicinae.com/
  imports = [ inputs.vicinae.homeManagerModules.default ];

  programs.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      target = "niri.service";
    };

    settings = lib.mkForce {
      # Match the Noctalia Crimson Voltage theme.
      theme = {
        dark = {
          name = "crimson-voltage";
          icon_theme = "default";
        };
        light = {
          name = "crimson-voltage-light";
          icon_theme = "default";
        };
      };

      font.normal = {
        size = 12;
        family = "JetBrainsMono Nerd Font";
      };

      launcher_window.opacity = 0.94;

      close_on_focus_loss = true;
      pop_to_root_on_close = true;
      consider_preedit = true;
    };

    themes = {
      crimson-voltage = {
        meta = {
          version = 1;
          name = "Crimson Voltage";
          description = "Deep navy shadows infused with high-voltage crimson energy";
          variant = "dark";
          inherits = "vicinae-dark";
        };

        colors = {
          core = {
            background = "#070b14";
            foreground = "#e6edf7";
            secondary_background = "#0a1220";
            border = "#3a1620";
            # Crimson accent role (matches Noctalia mPrimary)
            accent = "#ff4e66";
          };
          accents = {
            blue = "#3b82f6";
            green = "#4ade80";
            magenta = "#ff6e9c";
            orange = "#ff9f43";
            purple = "#a78bfa";
            red = "#ff4e66";
            yellow = "#ffd27d";
            cyan = "#38bdf8";
          };
        };
      };

      crimson-voltage-light = {
        meta = {
          version = 1;
          name = "Crimson Voltage Light";
          description = "Light variant of the Crimson Voltage palette";
          variant = "light";
          inherits = "vicinae-light";
        };

        colors = {
          core = {
            background = "#f1f5f9";
            foreground = "#0b0f1a";
            secondary_background = "#e6eef8";
            border = "#ffc1c9";
            accent = "#ff4e66";
          };
          accents = {
            blue = "#2563eb";
            green = "#16a34a";
            magenta = "#ff6e9c";
            orange = "#d97706";
            purple = "#a78bfa";
            red = "#ff4e66";
            yellow = "#f59e0b";
            cyan = "#0ea5e9";
          };
        };
      };
    };
  };
}
