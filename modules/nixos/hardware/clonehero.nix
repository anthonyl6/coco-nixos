{
  username,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    xwiimote
    evsieve
  ];

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "clonehero-udev-rules";
      text = ''
        KERNEL=="hidraw*", TAG+="uaccess"
        ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0306", TAG+="uaccess"
        KERNEL=="event*", ATTRS{name}=="Nintendo Wii Remote Guitar", SYMLINK+="input/wii-guitar", TAG+="systemd", ENV{SYSTEMD_WANTS}="wii-guitar-remap.service"
      '';
      destination = "/etc/udev/rules.d/69-hid.rules";
    })
  ];

  systemd.services.wii-guitar-remap = {
    description = "Remap Wii Guitar inputs to keyboard for YARG";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.evsieve}/bin/evsieve --input /dev/input/wii-guitar grab --map btn:1 key:f1 --map btn:2 key:f2 --map btn:3 key:f3 --map btn:4 key:f4 --map btn:5 key:f5 --map btn:dpad_up key:f6 --map btn:dpad_down key:f7 --map btn:select key:f8 --map btn:start key:f9 --output";
      Restart = "no";
    };
  };

  users.users.${username}.extraGroups = ["input"];
}
