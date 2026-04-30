# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs-stable, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/hardware/power-management.nix
    ./hardware-configuration.nix
    ./boot.nix
    ../../modules/nixos
  ];

  boot.kernelPackages = pkgs-stable.linuxPackages;

  networking.hostName = "coco";

  programs.zsh.enable = true;

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs-stable; [
    git
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
