{...}: let
  allowedPorts = [
  ];
in {
  networking.firewall = {
    enable = true;
    allowedTCPPorts = allowedPorts;
    allowedUDPPorts = allowedPorts;
  };
}
