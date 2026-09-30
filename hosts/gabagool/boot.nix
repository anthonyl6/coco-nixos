{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkForce false;
        consoleMode = "max";
      };
      limine = {
        enable = true;
        secureBoot.enable = true;

        # Windows 11 at nvme0n1p4 with its bootmgfw.efi on the shared ESP
        # (nvme0n1p1, same partition Limine boots from), so boot() resolves
        # there. If Windows ever gets a separate ESP, change this to
        # guid(<windows-esp-partuuid>):/EFI/Microsoft/Boot/bootmgfw.efi.
        extraEntries = ''
          /Windows
              protocol: efi
              path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
        '';

        extraConfig = ''
          term_palette: 1e1e2e;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4
          term_palette_bright: 585b70;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4
          term_background: 1e1e2e
          term_foreground: cdd6f4
          term_background_bright: 585b70
          term_foreground_bright: cdd6f4
        '';
        style = {
          wallpapers = [ ];
          interface = {
            resolution = "2880x1920";
            helpHidden = true;
            branding = "";
          };
          backdrop = lib.mkForce "1E1E2E";
        };
      };
      timeout = 5;
    };
    # Required to point at partition with swap for hibernation
    resumeDevice = "/dev/nvme0n1p3";
    plymouth = {
      enable = true;
      theme = lib.mkForce "dark_planet";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "dark_planet" ];
        })
      ];
    };
    # Shutdown hangs in the final systemd-shutdown phase (the last logged line
    # is "Syncing filesystems", then silence — consistent with the SN850X /
    # PCIe D3cold wedge documented under kernelParams above). The default
    # ShutdownWatchdogSec is 10min, so a hung shutdown "freezes" until the
    # hardware watchdog finally reboots; users power off first. 60s keeps the
    # hang self-recovering while still leaving time for a clean sync.
    # Remove once shutdowns are reliably clean.
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
    };
    # nvidia-drm.modeset/fbdev are contributed by hardware.nvidia.modesetting
    # in ../../modules/nixos/hardware/nvidia-egpu.nix, so they aren't repeated
    # here.
    #
    # WD_BLACK SN850X (the root/swap NVMe) wedges and throws I/O errors when
    # the platform enters s2idle - a known drive/firmware issue on AMD
    # platforms (ext4 "shut down requested", niri-session read I/O errors,
    # suspend hangs since at least Sep 3). Drive firmware 624361WD is already
    # the latest, and the kernel already applies its "simple suspend" platform
    # quirk, so stop the drive and its PCIe link from entering deep power
    # states around sleep:
    # - nvme_core.default_ps_max_latency_us=0: disables APST (drive-side
    #   autonomous power state transitions).
    # - pcie_aspm=off: disables PCIe link power management (the SN850X
    #   controller is known to fail ASPM state transitions). Costs some idle
    #   power; try removing after suspend has been stable for a while.
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log-priority=3"
      "rd.systemd.show_status=auto"
      "nvme_core.default_ps_max_latency_us=0"
      "pcie_aspm=off"
      # Suspending intermittently hangs during device suspend (journal ends at
      # "PM: suspend entry"). Keep printk flowing to the console while
      # suspending so the last "calling <device> suspend" line stays visible
      # on the built-in panel when it hangs. Remove once root-caused.
      "no_console_suspend"
    ];
  };

  systemd.settings.Manager = {
    # 60s (instead of the 10min default) — see the comment in boot.*
    ShutdownWatchdogSec = "60s";
  };

  # Suspending intermittently hangs during device suspend. This enables
  # per-device suspend/resume tracing ("calling <device> ..."), which with
  # no_console_suspend above identifies the culprit on a hang. Remove once
  # root-caused.
  systemd.tmpfiles.rules = [
    "w /sys/power/pm_debug_messages - - - - 1"
    "w /sys/power/pm_print_times - - - - 1"
  ];
}
