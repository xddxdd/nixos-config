{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  # SSDP, NAT-PMP and the UPnP HTTP description server are LAN-only by policy
  lantian.firewall.zones = {
    LAN.udpPorts = {
      "${LT.portStr.SSDP}".type = "local";
      "${LT.portStr.NATPMP}".type = "local";
    };
    LAN.tcpPorts."${LT.portStr.MiniUPnP.HTTP}".type = "local";
  };

  services.miniupnpd = {
    enable = true;
    upnp = true;
    natpmp = true;
    # Without http_port the daemon binds 0 and the kernel picks an ephemeral
    # port, which the firewall's ephemeral rules accept from WAN.
    appendConfig = "http_port=${LT.portStr.MiniUPnP.HTTP}";
  };

  systemd.services.miniupnpd = {
    serviceConfig = {
      # The NixOS module owns the nftables chains; legacy hooks are iptables-only.
      ExecStartPre =
        lib.mkIf (!config.networking.nftables.enable)
          "${lib.getExe pkgs.bash} -x ${pkgs.miniupnpd}/etc/miniupnpd/iptables_init.sh -i ${config.services.miniupnpd.externalInterface}";
      ExecStopPost =
        lib.mkIf (!config.networking.nftables.enable)
          "${lib.getExe pkgs.bash} -x ${pkgs.miniupnpd}/etc/miniupnpd/iptables_removeall.sh -i ${config.services.miniupnpd.externalInterface}";

      ProtectKernelModules = false;
      ProtectKernelTunables = false;
      # nftables needs CAP_NET_ADMIN in the host network namespace.
      PrivateUsers = false;
      # Port-in-use checks and interface statistics read /proc/net.
      ProcSubset = "all";

      BindPaths = [
        "/run"
        "/var/run"
      ];

      Restart = "always";
      RestartSec = "3";
    };
  };
  lantian.harden.miniupnpd.enable = "network";
}
