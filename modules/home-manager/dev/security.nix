# Security / pentest tooling — mirrors a typical Kali Linux install.
# System-level config (wireshark group, nmap caps) lives in
# modules/nixos/security/tools.nix.
{
  pkgs-fresh,
  pkgs-stable,
  ...
}:
let
  # responder reads its config from Responder.conf next to Responder.py in
  # the package share dir (settings.py: os.path.dirname(__file__)), which is
  # read-only in the store. Overlay our editable copy from cfg/responder/
  # onto the package.
  responder-custom = pkgs-stable.symlinkJoin {
    name = "responder-custom";
    paths = [ pkgs-stable.responder ];
    postBuild = ''
      ln -sf ${../../../cfg/responder/Responder.conf} \
        $out/share/Responder/Responder.conf
    '';
  };
in
{
  home.packages = with pkgs-stable; [
    # ── NTLM / Active Directory poisoning & relay ─────────────────────────────
    # Firewall ports for these are controlled by `pentest-firewall`
    # (modules/nixos/security/pentest.nix) — off by default.
    responder-custom   # LLMNR / NBT-NS / mDNS poisoner + rogue auth servers
                       # conf: cfg/responder/Responder.conf
    netexec            # NetExec (nxc) — maintained CrackMapExec fork
    smbmap             # SMB share enumeration
    # NOTE: mitm6 removed — nixpkgs still ships its deprecated `future`
    # dependency which cannot build on python3.13.
    pkgs-stable.python3Packages.impacket  # secretsdump.py, psexec.py, etc.
    pkgs-stable.python3Packages.certipy-ad  # AD certificate attacks

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
    # openssl is already in the environment via other packages

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
