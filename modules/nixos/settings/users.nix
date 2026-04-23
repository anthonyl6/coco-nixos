{
  inputs,
  username,
  fullName,
  pkgs-stable,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    ../../home-manager/default.nix
  ];
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    shell = pkgs-stable.zsh;
    openssh.authorizedKeys.keyFiles = [
      ../../../ssh/authorized_keys
    ];
  };

  # Enable automatic login for the user.
  # services = {
  #   displayManager.autoLogin.enable = true;
  #   displayManager.autoLogin.user = username;
  # };
}
