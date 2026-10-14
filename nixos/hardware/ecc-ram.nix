{ LT, ... }:
{
  hardware.rasdaemon.enable = true;

  services.prometheus.exporters.rasdaemon = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.RasdaemonExporter;
  };

  systemd.services.rasdaemon.serviceConfig.RestartSec = "5s";
  systemd.services."prometheus-rasdaemon-exporter".serviceConfig.RestartSec = "5s";
}
