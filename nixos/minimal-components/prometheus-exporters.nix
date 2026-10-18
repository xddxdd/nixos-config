{ LT, ... }:
{
  systemd.services."prometheus-node-exporter".serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
    # Collects host-wide /proc and /sys metrics; MountAPIVFS (via confinement)
    # mounts the real host procfs/sysfs inside the chroot
    ProcSubset = "all";
    ProtectProc = "default";
    # systemd collector talks to the host systemd over a unix socket
    BindReadOnlyPaths = [ "/run/systemd/private" ];
  };

  systemd.services."prometheus-node-exporter".confinement = { enable = true; fullUnit = true; };

  services.prometheus.exporters = {
    node = {
      enable = !(LT.this.hasTag LT.tags.client);
      port = LT.port.Prometheus.NodeExporter;
      listenAddress = LT.this.ltnet.IPv4;
      enabledCollectors = [ "systemd" ];
    };
  };
}
