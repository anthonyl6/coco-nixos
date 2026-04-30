{
  pkgs-fresh,
  username,
  ...
}:
{
  services.resolved.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };
  hardware.xone.enable = true;
  services.getty.autologinUser = username;
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs-fresh; [
      mangohud
      steam-run
    ];
    loginShellInit = ''
      [[ "$(tty)" = "/dev/tty1" ]] && ./gs.sh
    '';
  };
}
