{
  pkgs,
  config,
  ...
}: let
  # Root-only implementation — no sudo inside.
  # This is executed by the system-level systemd service as root.
  nvidia-egpu-load-impl = pkgs.writeShellScriptBin "nvidia-egpu-load-impl" ''
    set -e

    echo "0. Checking whether an NVIDIA eGPU is connected..."

    GPU_PRESENT=$(
      ${pkgs.pciutils}/bin/lspci -d 10de: -D \
        | ${pkgs.gnugrep}/bin/grep -E "VGA|3D" \
        || true
    )

    if [ -z "$GPU_PRESENT" ]; then
      echo "No NVIDIA eGPU detected. Nothing to do."
      exit 0
    fi

    echo "eGPU detected, proceeding."
    echo "$GPU_PRESENT"

    TB_ROOT="0000:00:01.1"

    echo "1. Removing Thunderbolt PCI branch to force clean re-enumeration..."

    if [ -e "/sys/bus/pci/devices/$TB_ROOT" ]; then
      echo "Removing PCI device $TB_ROOT"
      echo 1 > "/sys/bus/pci/devices/$TB_ROOT/remove"
      sleep 2
    else
      echo "Thunderbolt PCI root $TB_ROOT not present."
    fi

    echo "2. Rescanning PCI bus..."

    echo 1 > /sys/bus/pci/rescan
    sleep 3

    echo "Checking for NVIDIA GPU after rescan..."

    GPU_PCI=$(
      ${pkgs.pciutils}/bin/lspci -d 10de: -D \
        | ${pkgs.gnugrep}/bin/grep -E "VGA|3D" \
        | ${pkgs.coreutils}/bin/head -n1 \
        | ${pkgs.gawk}/bin/awk '{print $1}'
    )

    if [ -z "$GPU_PCI" ]; then
      echo "Error: eGPU was detected earlier but is gone after rescan."
      echo "Current NVIDIA PCI devices:"
      ${pkgs.pciutils}/bin/lspci -d 10de: -D || true
      exit 1
    fi

    echo "Found NVIDIA GPU at $GPU_PCI"

    echo "PCI device details:"
    ${pkgs.pciutils}/bin/lspci -nnk -s "$GPU_PCI" || true

    echo "3. Inserting NVIDIA driver modules..."

    echo "Loading nvidia..."
    ${pkgs.kmod}/bin/modprobe nvidia

    echo "Loading nvidia_modeset..."
    ${pkgs.kmod}/bin/modprobe nvidia_modeset

    echo "Loading nvidia_uvm..."
    ${pkgs.kmod}/bin/modprobe nvidia_uvm

    echo "Loading nvidia_drm..."
    ${pkgs.kmod}/bin/modprobe nvidia_drm

    echo "4. NVIDIA modules currently loaded:"
    ${pkgs.kmod}/bin/lsmod | ${pkgs.gnugrep}/bin/grep nvidia || true

    echo "5. Final NVIDIA PCI state:"
    ${pkgs.pciutils}/bin/lspci -nnk -d 10de: -D || true

    echo "NVIDIA eGPU initialized successfully!"
  '';

  # Manual CLI wrapper for terminal use.
  # This still prompts for your password when run manually.
  load-nvidia-egpu = pkgs.writeShellScriptBin "load-nvidia-egpu" ''
    exec sudo ${nvidia-egpu-load-impl}/bin/nvidia-egpu-load-impl
  '';

  # Run an application using the NVIDIA eGPU.
  egpu-offload = pkgs.writeShellScriptBin "egpu-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=Nvidia_only
    exec "$@"
  '';
in {
  boot.kernelParams = [
    "pci=realloc"
    "pci=realloc=on"
    "pcie_port_pm=off"
    "pci=hpmemsize=2G,hpmemsize1M=0"
    "pci=hpbussize=0x20"
  ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_OpenRmEnableUnsupportedGpus=1
    options nvidia_drm modeset=1 fbdev=1
  '';

  boot.blacklistedKernelModules = [
    "nouveau"
  ];

  boot.extraModulePackages = [
    config.hardware.nvidia.package
  ];

  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];

  services.hardware.bolt.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = false;
    nvidiaSettings = true;
  };

  # System-level service that performs the actual PCI rescan
  # and NVIDIA driver loading as root.
  #
  # It is NOT enabled at boot.
  # It only runs when explicitly started.
  systemd.services.nixos-load-nvidia-egpu = {
    description = "Load NVIDIA eGPU (PCI rescan + driver modules) if connected";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${nvidia-egpu-load-impl}/bin/nvidia-egpu-load-impl";
    };

    # No wantedBy: never auto-start on its own.
  };

  # Allow users to start only this specific system service
  # without a password.
  security.sudo.extraRules = [
    {
      users = ["ALL"];

      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start nixos-load-nvidia-egpu.service";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Automatically trigger the root-level loader once the
  # niri user service starts.
  #
  # /run/wrappers/bin/sudo is the NixOS setuid sudo wrapper.
  systemd.user.services.nvidia-egpu-autoload = {
    description = "Auto-load NVIDIA eGPU once niri session starts, if connected";

    partOf = [
      "niri.service"
    ];

    wantedBy = [
      "niri.service"
    ];

    serviceConfig = {
      Type = "oneshot";

      ExecStart =
        "/run/wrappers/bin/sudo "
        + "/run/current-system/sw/bin/systemctl "
        + "start nixos-load-nvidia-egpu.service";
    };
  };

  environment.systemPackages = with pkgs; [
    load-nvidia-egpu
    egpu-offload
    pciutils
    config.hardware.nvidia.package
  ];
}
