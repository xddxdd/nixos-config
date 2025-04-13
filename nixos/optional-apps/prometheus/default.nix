{
  lib,
  LT,
  config,
  ...
}:
let
  scrapeAllNonClientNodes = jobName: port: {
    job_name = jobName;
    static_configs = lib.mapAttrsToList (n: v: {
      targets = [ "${v.ltnet.IPv4}:${builtins.toString port}" ];
      labels.job = jobName;
      labels.instance = n;
    }) (LT.hostsWithoutTag LT.tags.client);
  };
  scrapeAllNonClientNodesNetns = jobName: index: port: {
    job_name = jobName;
    static_configs = lib.mapAttrsToList (n: v: {
      targets = [ "${v.ltnet.IPv4Prefix}.${builtins.toString index}:${builtins.toString port}" ];
      labels.job = jobName;
      labels.instance = n;
      labels.index = builtins.toString index;
    }) (LT.hostsWithoutTag LT.tags.client);
  };
in
{
  imports = [
    ./alertmanager.nix
    ./blackbox-exporter.nix
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

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}"
            ];
          }
        ];
      }
      (scrapeAllNonClientNodes "bird" LT.port.Prometheus.BirdExporter)
      (scrapeAllNonClientNodes "mysql" LT.port.Prometheus.MySQLExporter)
      (scrapeAllNonClientNodes "node" LT.port.Prometheus.NodeExporter)
      (scrapeAllNonClientNodes "postgres" LT.port.Prometheus.PostgresExporter)
      (scrapeAllNonClientNodesNetns "coredns" 56 LT.port.Prometheus.CoreDNS)
      (scrapeAllNonClientNodesNetns "coredns-authoritative" 54 LT.port.Prometheus.CoreDNS)
      {
        job_name = "palworld";
        static_configs = [
          { targets = [ "${LT.hosts."lt-home-vm".ltnet.IPv4}:${LT.portStr.Prometheus.Palworld}" ]; }
        ];
      }
      {
        job_name = "sakura-share";
        scheme = "https";
        static_configs = [
          { targets = [ "sakura-share.one" ]; }
        ];
      }
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

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
