{ LT, ... }:
{
  imports = [ ../optional-cron-jobs/smart-check ];

  services.prometheus.exporters.smartctl = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.SmartctlExporter;
  };

  systemd.services."prometheus-smartctl-exporter".serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
  };
}
