{
  username,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    xwiimote
  ];

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "clonehero-udev-rules";
      text = ''
        KERNEL=="hidraw*", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/69-hid.rules";
    })
  ];

  users.users.${username}.extraGroups = ["input"];
}
