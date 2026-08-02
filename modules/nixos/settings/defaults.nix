{ username, pkgs-stable, ... }:
{
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager.enable = true; # enable network manager
  time.timeZone = "America/Edmonton"; # set timezone
  i18n.defaultLocale = "en_CA.UTF-8"; # set locale
  services.xserver.enable = true; # enables x11
  services.fwupd.enable = true; # enable firmware updates
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBw="
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
  # Basic packages used everywhere
  environment.systemPackages = with pkgs-stable; [
    wget
    curl
  ];

  users.users.${username}.extraGroups = [
    "networkmanager"
    "wheel"
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
