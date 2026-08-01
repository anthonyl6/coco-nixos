{config, ...}: {
  programs.gamescope = {
    enable = builtins.elem config.networking.hostName ["coco" "cocolaptop"];
    capSysNice = true;
  };
}
