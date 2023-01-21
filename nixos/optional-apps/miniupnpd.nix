{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  services.miniupnpd = {
    enable = true;
    upnp = true;
    natpmp = true;
  };

  systemd.services.miniupnpd.serviceConfig = {
    ExecStartPre = "${pkgs.bash}/bin/bash -x ${pkgs.miniupnpd}/etc/miniupnpd/iptables_init.sh -i ${config.services.miniupnpd.externalInterface}";
    ExecStopPost = "${pkgs.bash}/bin/bash -x ${pkgs.miniupnpd}/etc/miniupnpd/iptables_removeall.sh -i ${config.services.miniupnpd.externalInterface}";
  };
}
