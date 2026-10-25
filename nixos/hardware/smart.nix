{ LT, ... }:
{
  imports = [ ../optional-cron-jobs/smart-check ];

  services.prometheus.exporters.smartctl = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.SmartctlExporter;
  };

  systemd.services."prometheus-smartctl-exporter".serviceConfig = {
    RestartSec = "5s";
    # Reads SMART data via device ioctls
    PrivateUsers = false;
    PrivateDevices = false;
  };
  lantian.harden."prometheus-smartctl-exporter".enable = true;
}
