{
  username,
  lib,
  inputs,
  stdenv,
  ...
}:
{
  # Noctalia v5 desktop shell settings.
  # Reference: https://docs.noctalia.dev/noctalia/configuration/
  wayland.systemd.target = "niri.service";

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${stdenv.hostPlatform.system}.default;
    systemd.enable = true;

    settings = lib.mkForce {
      shell = {
        font_family = "JetBrainsMono Nerd Font";
        corner_radius_scale = 1.15;
        settings_show_advanced = true;
        telemetry_enabled = false;
        offline_mode = true;
        niri_overview_type_to_launch_enabled = true;
      };

      shell.panel = {
        transparency_mode = "glass";
        launcher_placement = "floating";
        clipboard_placement = "floating";
        control_center_placement = "floating";
        wallpaper_placement = "floating";
        session_placement = "floating";
      };

      shell.animation = {
        enabled = true;
        speed = 1.0;
      };

      shell.launcher = {
        app_grid = true;
        sort_by_usage = true;
        pinned = [ "zen" "ghostty" "thunar" ];
      };

      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "CrimsonVoltage";
        pure_black_dark = true;
      };

      wallpaper = {
        enabled = true;
        directory = "/home/${username}/walls";
        fill_mode = "crop";
        transition = [ "fade" ];
        transition_duration = 1800;
        transition_on_startup = false;
      };

      wallpaper.automation = {
        # Disabled: random rotation kept grabbing the colourful dark-knight
        # wallpaper. The B&W mirror wallpaper is pinned below instead.
        enabled = false;
        interval_seconds = 1800;
        order = "random";
        # false so a future shuffle only picks from the B&W images in the root;
        # colour wallpapers live in walls/colour and stay out of rotation.
        recursive = false;
      };

      # Pin the black & white bonfire wallpaper as the default for all monitors.
      wallpaper.default.path = "/home/${username}/walls/bonfire-bw.jpg";

      notification = {
        enable_daemon = true;
        background_opacity = 0.95;
      };

      osd = {
        position = "top_center";
        background_opacity = 0.95;
      };

      lockscreen = {
        enabled = true;
        blurred_desktop = false;
        tint_intensity = 0.4;
      };

      audio.enable_overdrive = true;

      bar.main = {
        position = "top";
        thickness = 38;
        radius = 14;
        background_opacity = 0.85;
        corner_radius_scale = 1.0;
        margin_edge = 10;
        margin_ends = 160;
        widget_spacing = 8;
        shadow = true;
        capsule = true;
        capsule_fill = "surface_variant";
        capsule_opacity = 0.9;
        start = [ "launcher" "workspaces" ];
        center = [ "clock" ];
        end = [
          "media"
          "tray"
          "notifications"
          "clipboard"
          "network"
          "volume"
          "battery"
          "raycursive/niri-displays:bar"
          "control-center"
          "session"
        ];
      };

      widget.clock.format = "{:%H:%M}\n{:%a %d %b}";

      dock = {
        enabled = true;
        position = "bottom";
        icon_size = 32;
        main_axis_padding = 10;
        cross_axis_padding = 4;
        item_spacing = 4;
        background_opacity = 0.7;
        radius = 10;
        magnification = true;
        magnification_scale = 1.2;
        margin_edge = 8;
        shadow = true;
        show_dots = true;
        show_instance_count = false;
        active_opacity = 1.0;
        inactive_opacity = 0.55;
        pinned = [ "zen" "ghostty" "thunar" "discord" ];
      };

      desktop_widgets = {
        enabled = true;
        widget_order = [ "clock_main" ];
      };

      desktop_widgets.widget.clock_main = {
        type = "clock";
        cx = 960.0;
        cy = 540.0;
        scale = 1.5;
      };

      desktop_widgets.widget.clock_main.settings = {
        format = "{:%H:%M}";
        background_opacity = 0.75;
      };

      # Plugins: enable declaratively here (survives regeneration, unlike the
      # Settings UI toggle which Noctalia stores as a runtime override).
      # raycursive/niri-displays comes from the built-in "community" git source.
      plugins.enabled = [ "raycursive/niri-displays" ];

      control_center.shortcuts = [
        { type = "wifi"; }
        { type = "bluetooth"; }
        { type = "nightlight"; }
        { type = "wallpaper"; }
        { type = "screen_recorder"; }
        { type = "session"; }
      ];
    };

    customPalettes = {
      # Black & white (monochrome) palette — matches the B&W wallpaper rice.
      "CrimsonVoltage".dark = {
        mPrimary = "#e6edf7";
        mOnPrimary = "#0b0f1a";
        mSecondary = "#cbd5e1";
        mOnSecondary = "#0b0f1a";
        mTertiary = "#94a3b8";
        mOnTertiary = "#0b0f1a";
        mError = "#e6edf7";
        mOnError = "#0b0f1a";
        mSurface = "#0a0a0c";
        mOnSurface = "#e6edf7";
        mSurfaceVariant = "#17171b";
        mOnSurfaceVariant = "#cbd5e1";
        mOutline = "#94a3b8";
        mShadow = "#050505";
        mHover = "#23232b";
        mOnHover = "#e6edf7";

        # v5 palettes MUST include a terminal object — the parser rejects the
        # variant otherwise and silently falls back to the builtin palette.
        terminal = {
          background = "#050505";
          foreground = "#e6edf7";
          cursor = "#e6edf7";
          cursorText = "#050505";
          selectionBg = "#23232b";
          selectionFg = "#f4f4f6";
          normal = {
            black = "#17171b";
            red = "#c0c0c8";
            green = "#b8bcc4";
            yellow = "#e6edf7";
            blue = "#7e7e88";
            magenta = "#d1d5db";
            cyan = "#9ca3af";
            white = "#e6edf7";
          };
          bright = {
            black = "#4b4b52";
            red = "#c0c0c8";
            green = "#d8d8de";
            yellow = "#f4f4f6";
            blue = "#8e8e98";
            magenta = "#e8e8ec";
            cyan = "#b4b4bc";
            white = "#cbd5e1";
          };
        };
      };
      "CrimsonVoltage".light = {
        mPrimary = "#1a1a1e";
        mOnPrimary = "#f1f5f9";
        mSecondary = "#4b5563";
        mOnSecondary = "#f1f5f9";
        mTertiary = "#6b7280";
        mOnTertiary = "#f1f5f9";
        mError = "#1a1a1e";
        mOnError = "#f1f5f9";
        mSurface = "#f1f5f9";
        mOnSurface = "#1a1a1e";
        mSurfaceVariant = "#e2e8f0";
        mOnSurfaceVariant = "#2d2d33";
        mOutline = "#6b7280";
        mShadow = "#e6eef8";
        mHover = "#dde3ea";
        mOnHover = "#1a1a1e";

        terminal = {
          background = "#f1f5f9";
          foreground = "#1a1a1e";
          cursor = "#1a1a1e";
          cursorText = "#f1f5f9";
          selectionBg = "#dde3ea";
          selectionFg = "#1a1a1e";
          normal = {
            black = "#f1f5f9";
            red = "#4b4b52";
            green = "#b4b4bc";
            yellow = "#1a1a1e";
            blue = "#9ca3af";
            magenta = "#6b7280";
            cyan = "#8e8e98";
            white = "#1a1a1e";
          };
          bright = {
            black = "#d1d5db";
            red = "#4b4b52";
            green = "#94a3b8";
            yellow = "#17171b";
            blue = "#7e7e88";
            magenta = "#4b4b52";
            cyan = "#6b7280";
            white = "#050505";
          };
        };
      };
    };
  };

  # Ensure fonts Noctalia references actually exist.
  home.packages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
    jetbrains-mono
  ];

  # The runtime config lives in ~/.config/noctalia and is mutable; the TOML we
  # generate is used as the Nix-managed seed (hot-reloadable overrides are
  # edited via the Noctalia settings UI afterwards).
  # NOTE: programs.noctalia.settings is linked to
  # ~/.config/noctalia/config.toml via the upstream home module.
}
