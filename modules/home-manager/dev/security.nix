# Security / pentest tooling — mirrors a typical Kali Linux install.
# System-level config (wireshark group, nmap caps) lives in
# modules/nixos/security/tools.nix.
{ pkgs-fresh, pkgs-stable, ... }:
{
  home.packages = with pkgs-stable; [
    # ── Network scanning ──────────────────────────────────────────────────────
    nmap        # includes ncat; needs sudo for SYN/OS-detect scans
    masscan     # fast TCP port scanner
    rustscan    # wrapper around nmap with fast async discovery
    arp-scan    # ARP host discovery on local LAN
    netdiscover # passive/active ARP scanner

    # ── Packet analysis ───────────────────────────────────────────────────────
    # wireshark-qt GUI is managed by programs.wireshark in nixos/security/tools
    tcpdump     # classic CLI packet capture (needs sudo)
    wireshark-cli  # tshark + dumpcap; shares the setuid dumpcap from nixos module

    # ── Web testing ───────────────────────────────────────────────────────────
    gobuster    # directory / DNS / vhost bruteforce
    ffuf        # fast web fuzzer
    sqlmap      # automated SQL injection
    nikto       # web server scanner
    whatweb     # web fingerprinting
    pkgs-fresh.burpsuite  # web proxy / interceptor (unfree)

    # ── Password testing ──────────────────────────────────────────────────────
    hashcat     # GPU-accelerated hash cracker
    john        # CPU hash cracker (john the ripper)
    thc-hydra   # online brute-force (SSH, FTP, HTTP, etc.)

    # ── SSL / TLS ─────────────────────────────────────────────────────────────
    sslscan     # TLS version / cipher enumeration
    openssl     # Swiss-army knife for certs and crypto

    # ── Enumeration ───────────────────────────────────────────────────────────
    enum4linux-ng  # SMB / LDAP enumeration (Samba targets)

    # ── Exploitation / research ───────────────────────────────────────────────
    exploitdb   # searchsploit — local offline copy of Exploit-DB
    pwntools    # CTF / exploit development library + CLI

    # ── Network utilities ─────────────────────────────────────────────────────
    socat       # multipurpose relay (netcat on steroids)
    netcat-gnu  # plain nc for quick listeners / transfers
    proxychains-ng  # route traffic through proxy chains
    whois       # domain / IP WHOIS lookups
    inetutils   # telnet, ftp, traceroute, etc.

    # ── DNS ───────────────────────────────────────────────────────────────────
    dnsutils    # dig, nslookup, host (bind-tools)

    # ── Wireless ─────────────────────────────────────────────────────────────
    aircrack-ng # WEP/WPA key cracking suite

    # ── Uncomment to add Metasploit (large download, unfree) ─────────────────
    # pkgs-fresh.metasploit
  ];
}
