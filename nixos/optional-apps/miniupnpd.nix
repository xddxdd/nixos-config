{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  # SSDP and NAT-PMP are LAN-only by policy
  lantian.firewall.presets.public-firewall.allowedInternalPorts = [
    LT.port.SSDP
    LT.port.NATPMP
  ];

  services.miniupnpd = {
    enable = true;
    upnp = true;
    natpmp = true;
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
