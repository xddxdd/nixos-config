{ lib, ... }:
{
  imports = [ ../hardware/vfio.nix ];

  services.proxmox-ve.enable = true;

  systemd.services.pvescheduler.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
  systemd.services.qmeventd.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };

  services.scx.enable = lib.mkForce false;
  zramSwap.enable = lib.mkForce false;
}
