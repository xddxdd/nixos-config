{
  LT,
  ...
}:
{
  imports = [
    ./alertmanager.nix
    ./blackbox-exporter.nix
    ./periodic-tasks.nix
    ./scrape-configs.nix
    ./storagebox.nix
  ];

  services.prometheus = {
    enable = true;
    port = LT.port.Prometheus.Daemon;
    listenAddress = "127.0.0.1";
    webExternalUrl = "https://prometheus.xuyh0120.win";
    stateDir = "prometheus";
    checkConfig = "syntax-only";

    extraFlags = [
      "--storage.tsdb.retention.time=365d"
      "--storage.tsdb.retention.size=10GB"
    ];
  };

  systemd.services.prometheus.serviceConfig = LT.serviceHarden;

  lantian.nginxVhosts."prometheus.xuyh0120.win" = {
    locations = {
      "/" = {
        enableOAuth = true;
        proxyPass = "http://127.0.0.1:${LT.portStr.Prometheus.Daemon}";
      };
    };

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
  };
}
