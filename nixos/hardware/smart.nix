{ LT, ... }:
{
  imports = [ ../optional-cron-jobs/smart-check ];

  services.prometheus.exporters.smartctl = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.SmartctlExporter;
  };
}
