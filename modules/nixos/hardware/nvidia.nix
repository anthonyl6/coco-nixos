{pkgs, ...}: {
  services.xserver.videoDrivers = ["nvidia" "amdgpu"];

  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
    };
  };
}
