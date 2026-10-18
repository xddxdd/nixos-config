{
  pkgs,
  lib,
  config,
  LT,
  ...
}:
{
  services.miniupnpd = {
    enable = true;
    upnp = true;
    natpmp = true;
  };

  systemd.services.miniupnpd = {
    serviceConfig = LT.networkToolHarden // {
      ExecStartPre = "${lib.getExe pkgs.bash} -x ${pkgs.miniupnpd}/etc/miniupnpd/iptables_init.sh -i ${config.services.miniupnpd.externalInterface}";
      ExecStopPost = "${lib.getExe pkgs.bash} -x ${pkgs.miniupnpd}/etc/miniupnpd/iptables_removeall.sh -i ${config.services.miniupnpd.externalInterface}";

      ProtectKernelModules = false;
      ProtectKernelTunables = false;

      BindPaths = [
        "/run"
        "/var/run"
      ];

      Restart = "always";
      RestartSec = "3";
    };
    confinement = {
      enable = true;
      fullUnit = true;
    };
  };
}
