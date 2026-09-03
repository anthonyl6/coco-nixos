{ pkgs-stable, username, ... }:

# VPN bypass network namespace — works on WiFi and Ethernet.
#
# macvlan requires Ethernet (APs only allow one MAC per client), so this uses
# a veth pair + policy routing + NAT instead:
#
#   host side:  veth-bypass-host  10.200.200.1/24
#   namespace:  veth-bypass-ns    10.200.200.2/24 -> default via 10.200.200.1
#
# Traffic from the namespace is looked up in routing table 200, which routes
# directly via the physical default gateway — bypassing any VPN routes in the
# main table — and is then masqueraded as the host's physical IP.
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "${pkgs-stable.iproute2}/bin/ip netns exec vpn-bypass *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = with pkgs-stable; [
    iproute2
    iptables
  ];

  systemd.services.netns-vpn-bypass = {
    description = "VPN bypass namespace (veth + policy routing + NAT)";

    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs-stable; [
      iproute2
      iptables
      coreutils
      gnugrep
      gawk
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStop = pkgs-stable.writeShellScript "netns-cleanup" ''
        iptables -t nat -D POSTROUTING -s 10.200.200.0/24 -j MASQUERADE 2>/dev/null || true
        iptables -D FORWARD -s 10.200.200.0/24 -j ACCEPT 2>/dev/null || true
        iptables -D FORWARD -d 10.200.200.0/24 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
        ip rule del from 10.200.200.0/24 lookup 200 priority 100 2>/dev/null || true
        ip route flush table 200 2>/dev/null || true
        ip netns del vpn-bypass 2>/dev/null || true
        ip link del veth-bypass-host 2>/dev/null || true
      '';
    };

    script = ''
      set -euo pipefail

      PHYS_IF=$(ip route show default | awk 'NR==1 {print $5}')
      GW=$(ip route show default | awk 'NR==1 {print $3}')

      if [ -z "$PHYS_IF" ] || [ -z "$GW" ]; then
        echo "No default route found — is the network up?"
        exit 1
      fi

      echo "Physical interface: $PHYS_IF, gateway: $GW"

      # Clean up any leftover state
      ip netns del vpn-bypass      2>/dev/null || true
      ip link del veth-bypass-host 2>/dev/null || true
      ip rule del from 10.200.200.0/24 lookup 200 priority 100 2>/dev/null || true
      ip route flush table 200 2>/dev/null || true

      # Namespace + veth pair
      ip netns add vpn-bypass
      ip link add veth-bypass-host type veth peer name veth-bypass-ns
      ip link set veth-bypass-ns netns vpn-bypass

      # Host side
      ip addr add 10.200.200.1/24 dev veth-bypass-host
      ip link set veth-bypass-host up

      # Namespace side
      ip -n vpn-bypass addr add 10.200.200.2/24 dev veth-bypass-ns
      ip -n vpn-bypass link set lo up
      ip -n vpn-bypass link set veth-bypass-ns up
      ip -n vpn-bypass route add default via 10.200.200.1

      # Policy routing: namespace traffic bypasses VPN routes in main table
      ip route add default via "$GW" dev "$PHYS_IF" table 200
      ip route add 10.200.200.0/24 dev veth-bypass-host table 200
      ip rule add from 10.200.200.0/24 lookup 200 priority 100

      # NAT: masquerade as host physical IP
      iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -j MASQUERADE
      iptables -A FORWARD -s 10.200.200.0/24 -j ACCEPT
      iptables -A FORWARD -d 10.200.200.0/24 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

      # Firewall inside namespace
      ip netns exec vpn-bypass iptables -P INPUT DROP
      ip netns exec vpn-bypass iptables -P FORWARD DROP
      ip netns exec vpn-bypass iptables -P OUTPUT ACCEPT
      ip netns exec vpn-bypass iptables -A INPUT -i lo -j ACCEPT
      ip netns exec vpn-bypass iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      # IPv6 leak prevention
      ip netns exec vpn-bypass sysctl -w net.ipv6.conf.all.disable_ipv6=1    >/dev/null
      ip netns exec vpn-bypass sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null

      echo "VPN bypass namespace ready (10.200.200.2 -> $GW via $PHYS_IF)"
    '';
  };
}
