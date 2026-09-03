{...}: {
  security = {
    sudo.enable = true;
    rtkit.enable = true;

    pam.services = {
      "polkit-1".unixAuth = true;
      "sudo".unixAuth = true;
      login = {
        unixAuth = true;
        enableGnomeKeyring = true;
      };
      greetd.enableGnomeKeyring = true;
    };
  };

  services.gnome.gnome-keyring.enable = true;
}
