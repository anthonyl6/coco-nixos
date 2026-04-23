{
  inputs,
  stdenv,
  config,
  username,
  fullName,
  email,
  pkgs-fresh,
  pkgs-stable,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit stdenv;
      inherit username;
      inherit fullName;
      inherit email;
      inherit pkgs-fresh;
      inherit pkgs-stable;
      hostname = config.networking.hostName;
    };
    users = {
      ${username} = import ./links.nix;
    };
    backupFileExtension = "bak";
  };
}
