{ pkgs-stable, ... }:
{
  services.tailscale = {
    enable = false;
    # Enable tailscale at startup

    # If you would like to use a preauthorized key
    #authKeyFile = "/run/secrets/tailscale_key";

  };
  environment.systemPackages = with pkgs-stable; [
    wireguard-tools
  ];
}
