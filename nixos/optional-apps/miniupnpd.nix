{ pkgs,
  lib, config, ... }:
{
  services.miniupnpd = {
    enable = true;
    upnp = true;
    natpmp = true;
  };

  systemd.services.miniupnpd.serviceConfig = {
    ExecStartPre = "${lib.getExe pkgs.bash} -x ${pkgs.miniupnpd}/etc/miniupnpd/iptables_init.sh -i ${config.services.miniupnpd.externalInterface}";
    ExecStopPost = "${lib.getExe pkgs.bash} -x ${pkgs.miniupnpd}/etc/miniupnpd/iptables_removeall.sh -i ${config.services.miniupnpd.externalInterface}";
  };
}
