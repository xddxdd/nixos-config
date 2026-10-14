{ ... }:
{
  imports = [ ../hardware/vfio.nix ];

  services.proxmox-ve.enable = true;

  systemd.services."pve-cluster".serviceConfig.RestartSec = "5s";
  systemd.services.pvedaemon.serviceConfig.RestartSec = "5s";
  systemd.services.pveproxy.serviceConfig.RestartSec = "5s";
  systemd.services.spiceproxy.serviceConfig.RestartSec = "5s";

  systemd.services.pvescheduler.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
  systemd.services.qmeventd.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
}
