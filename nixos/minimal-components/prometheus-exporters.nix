{ LT, ... }:
{
  systemd.services."prometheus-node-exporter".serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
    # Collects host-wide /proc and /sys metrics, which a confinement chroot
    # (fresh procfs/sysfs) cannot provide
    ProcSubset = "all";
    ProtectProc = "default";
    # systemd collector talks to the host systemd over a unix socket
    BindReadOnlyPaths = [ "/run/systemd/private" ];
  };

  services.prometheus.exporters = {
    node = {
      enable = !(LT.this.hasTag LT.tags.client);
      port = LT.port.Prometheus.NodeExporter;
      listenAddress = LT.this.ltnet.IPv4;
      enabledCollectors = [ "systemd" ];
    };
  };
}
