{ pkgs-stable, ... }:

{
  environment.systemPackages = with pkgs-stable; [
    iproute2
    dhcpcd
    iptables
  ];

  # --------------------------------------------------
  # VPN Bypass Network Namespace
  # --------------------------------------------------
  systemd.services.netns-vpn-bypass = {
    description = "VPN bypass namespace using macvlan + dhcpcd";

    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = [
      pkgs-stable.iproute2
      pkgs-stable.dhcpcd
      pkgs-stable.iptables
      pkgs-stable.coreutils
      pkgs-stable.gnugrep
      pkgs-stable.gawk
      pkgs-stable.procps
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStop = pkgs-stable.writeShellScript "netns-cleanup" ''
        ip netns exec vpn-bypass pkill -f dhcpcd 2>/dev/null || true
        ip netns del vpn-bypass 2>/dev/null || true
        ip link del mv-bypass 2>/dev/null || true
      '';
    };

    script = ''
      set -euo pipefail

      PHYS_IF=$(ip route | grep default | head -n1 | awk '{print $5}')

      if [ -z "$PHYS_IF" ]; then
        echo "No default interface found"
        exit 1
      fi

      # Cleanup old state
      ip netns del vpn-bypass 2>/dev/null || true
      ip link del mv-bypass 2>/dev/null || true

      # Create namespace
      ip netns add vpn-bypass

      # Create macvlan
      ip link add mv-bypass link "$PHYS_IF" type macvlan mode bridge
      ip link set mv-bypass netns vpn-bypass

      # Bring up interfaces
      ip -n vpn-bypass link set lo up
      ip -n vpn-bypass link set mv-bypass up

      # Disable IPv6 (leak prevention)
      ip netns exec vpn-bypass sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null
      ip netns exec vpn-bypass sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null

      # Firewall isolation
      ip netns exec vpn-bypass iptables -P INPUT DROP
      ip netns exec vpn-bypass iptables -P FORWARD DROP
      ip netns exec vpn-bypass iptables -P OUTPUT ACCEPT
      ip netns exec vpn-bypass iptables -A INPUT -i lo -j ACCEPT
      ip netns exec vpn-bypass iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      # DHCP
      ip netns exec vpn-bypass dhcpcd -b -q -4 mv-bypass

      # Wait for IP
      for i in $(seq 1 10); do
        if ip -n vpn-bypass addr show mv-bypass | grep -q "inet "; then
          echo "VPN bypass namespace ready"
          exit 0
        fi
        sleep 1
      done

      echo "Failed to get IP"
      exit 1
    '';
  };
}
