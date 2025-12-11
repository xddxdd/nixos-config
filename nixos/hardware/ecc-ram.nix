{ LT, ... }:
{
  hardware.rasdaemon.enable = true;

  services.prometheus.exporters.rasdaemon = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.RasdaemonExporter;
  };
}
