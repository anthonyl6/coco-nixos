# System-level security tool configuration.
# Packages are in modules/home-manager/dev/security.nix.
{ username, ... }:
{
  # Installs wireshark with a setuid dumpcap so unprivileged capture works.
  # Adds the user to the `wireshark` group — log out and back in after first
  # nixos-rebuild for group membership to take effect.
  programs.wireshark = {
    enable = true;
  };

  users.users.${username}.extraGroups = [ "wireshark" ];
}
