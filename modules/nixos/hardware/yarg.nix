{username, ...}: {
  services.udev.extraRules = ''
    # Allow YARG to access HID devices (PS3/Wii instruments)
    KERNEL=="hidraw*", MODE="0660", GROUP="input", TAG+="uaccess"

    # XBOX 360 Wireless Adapter compatibility
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="0291", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02a9", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="0719", MODE="0666"
  '';

  users.users.${username}.extraGroups = ["input"];
}
