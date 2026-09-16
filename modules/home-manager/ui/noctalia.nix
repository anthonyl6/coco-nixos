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
        enabled = true;
        interval_seconds = 1800;
        order = "random";
        recursive = true;
      };

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
          "control-center"
          "session"
        ];
      };

      widget.clock.format = "{:%H:%M}\n{:%a %d %b}";

      dock = {
        enabled = true;
        position = "bottom";
        icon_size = 46;
        background_opacity = 0.85;
        radius = 16;
        magnification = true;
        magnification_scale = 1.5;
        margin_edge = 10;
        shadow = true;
        show_dots = true;
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
      # Converted from the old DMS "Crimson Voltage" theme.
      "CrimsonVoltage".dark = {
        mPrimary = "#ff4e66";
        mOnPrimary = "#0b0f1a";
        mSecondary = "#ff9f43";
        mOnSecondary = "#0b0f1a";
        mTertiary = "#3b82f6";
        mOnTertiary = "#0b0f1a";
        mError = "#ff4e66";
        mOnError = "#0b0f1a";
        mSurface = "#0a0f1c";
        mOnSurface = "#e6edf7";
        mSurfaceVariant = "#111827";
        mOnSurfaceVariant = "#cbd5e1";
        mOutline = "#f57385";
        mShadow = "#070b14";
        mHover = "#3a1620";
        mOnHover = "#ffc1c9";
      };
      "CrimsonVoltage".light = {
        mPrimary = "#ff4e66";
        mOnPrimary = "#0b0f1a";
        mSecondary = "#d97706";
        mOnSecondary = "#ffffff";
        mTertiary = "#2563eb";
        mOnTertiary = "#ffffff";
        mError = "#ff4e66";
        mOnError = "#ffffff";
        mSurface = "#f1f5f9";
        mOnSurface = "#0b0f1a";
        mSurfaceVariant = "#e2e8f0";
        mOnSurfaceVariant = "#1e293b";
        mOutline = "#ff4e66";
        mShadow = "#e6eef8";
        mHover = "#ffc1c9";
        mOnHover = "#0b0f1a";
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
