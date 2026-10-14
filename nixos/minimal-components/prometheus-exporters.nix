{ LT, ... }:
{
  systemd.services."prometheus-node-exporter".serviceConfig.RestartSec = "5s";

  services.prometheus.exporters = {
    node = {
      enable = !(LT.this.hasTag LT.tags.client);
      port = LT.port.Prometheus.NodeExporter;
      listenAddress = LT.this.ltnet.IPv4;
      enabledCollectors = [ "systemd" ];
    };
  };
}
