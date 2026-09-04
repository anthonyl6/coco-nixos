{ ... }:
{
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  services.upower.enable = true;
}
