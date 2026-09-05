{pkgs, ...}: {
  # NVIDIA eGPU in a USB4/Thunderbolt enclosure, on top of the Strix Point
  # iGPU. amdgpu keeps driving the internal panel; the NVIDIA card is only
  # used for render offload, so it is deliberately *not* in videoDrivers
  # first and PRIME is left off (see below).
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
    };

    amdgpu = {
      initrd.enable = true;
      legacySupport.enable = true;
      opencl.enable = true;
    };
  };

  # Prevent greetd from starting before the NVIDIA eGPU has fully enumerated
  # on the PCIe bus. bolt.service authorizes the Thunderbolt enclosure, but
  # PCIe enumeration and nvidia module probe happen asynchronously after that.
  # We poll for /dev/nvidia0 with a 15 s timeout; if the eGPU isn't attached
  # the loop exits early and greetd starts normally on the iGPU.
  systemd.services.greetd = {
    after = [ "bolt.service" ];
    wants = [ "bolt.service" ];
    serviceConfig.ExecStartPre = pkgs.writeShellScript "wait-for-nvidia" ''
      for i in $(seq 1 30); do
        [ -e /dev/nvidia0 ] && exit 0
        sleep 0.5
      done
      exit 0
    '';
  };

  # No hardware.nvidia.prime here on purpose: PRIME wants a fixed nvidiaBusId,
  # but an eGPU's bus ID moves with the port it's plugged into, and the offload
  # env vars work fine under niri without it.
  environment.systemPackages = [
    pkgs.bolt
    (pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json
      exec "$@"
    '')
  ];
}
