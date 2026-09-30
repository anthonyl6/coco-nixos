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
            background = "#050505";
            foreground = "#e6edf7";
            secondary_background = "#141419";
            border = "#23232b";
            accent = "#e6edf7";
          };
          accents = {
            blue = "#b4b4bc";
            green = "#d1d5db";
            magenta = "#9ca3af";
            orange = "#cbd5e1";
            purple = "#8a8a93";
            red = "#7e7e88";
            yellow = "#f4f4f6";
            cyan = "#a1a1aa";
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
            foreground = "#1a1a1e";
            secondary_background = "#e6eef8";
            border = "#dde3ea";
            accent = "#1a1a1e";
          };
          accents = {
            blue = "#6b7280";
            green = "#4b5563";
            magenta = "#9ca3af";
            orange = "#d1d5db";
            purple = "#6b7280";
            red = "#374151";
            yellow = "#1f2937";
            cyan = "#9ca3af";
          };
        };
      };
    };
  };
}
