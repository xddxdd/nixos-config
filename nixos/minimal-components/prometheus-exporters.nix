{ LT, ... }:
{
  systemd.services."prometheus-node-exporter".serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
    # Collects host-wide /proc metrics
    ProcSubset = "all";
    ProtectProc = "default";
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
