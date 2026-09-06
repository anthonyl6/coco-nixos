{pkgs, ...}: {
  # NVIDIA eGPU in a USB4/Thunderbolt enclosure, on top of the Strix Point
  # iGPU. amdgpu keeps driving the internal panel; the NVIDIA card is only
  # used for render offload, so it is deliberately *not* in videoDrivers
  # first and PRIME is left off (see below).
  #
  # pci=realloc: the BIOS doesn't reserve enough PCI bus-number/MMIO space
  # behind the Thunderbolt root port for a device that's hot-added after
  # boot (or enumerates late during boot). Without this, the kernel logs
  # "bridge configuration invalid ([bus 00-00]), reconfiguring" and the
  # GPU gets stuck reporting D3cold with "fallen off the bus" no matter
  # what power-state/rescan tricks are applied afterward -- the fix has
  # to happen at initial resource allocation, not after the fact.
  boot.kernelParams = [
    "pci=realloc"
  ];

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
    "amdgpu"
  ];

  # Without bolt the enclosure never gets authorized and the GPU won't
  # enumerate on the PCIe bus at all. `boltctl enroll <uuid>` once per dock.
  services.hardware.bolt.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true; # steam / proton
    };

    nvidia = {
      modesetting.enable = true; # also supplies nvidia-drm.modeset=1 + fbdev=1
      open = true; # Turing and later: open modules are the recommended default
      nvidiaSettings = true;

      # Preserve VRAM across suspend. Turn this off first if resume misbehaves
      # with the enclosure attached.
      powerManagement.enable = true;

      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        amdgpuBusId = "PCI:193:0:0";
        nvidiaBusId = "PCI:6:0:0";
      };
    };

    amdgpu = {
      initrd.enable = true;
      legacySupport.enable = true;
      opencl.enable = true;
    };
  };
}
