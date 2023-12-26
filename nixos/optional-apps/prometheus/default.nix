{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  scrapeAllNodes = jobName: port: {
    job_name = jobName;
    static_configs =
      lib.mapAttrsToList
      (n: v: {
        targets = ["${v.ltnet.IPv4}:${builtins.toString port}"];
        labels.instance = n;
      })
      LT.serverHosts;
  };
in {
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

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = ["${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}"];
          }
        ];
      }
      (scrapeAllNodes "bird" LT.port.Prometheus.BirdExporter)
      (scrapeAllNodes "endlessh-go" LT.port.Prometheus.EndlesshGo)
      (scrapeAllNodes "mysql" LT.port.Prometheus.MySQLExporter)
      (scrapeAllNodes "node" LT.port.Prometheus.NodeExporter)
      (scrapeAllNodes "postgres" LT.port.Prometheus.PostgresExporter)
    ];
  };

  systemd.services.prometheus.serviceConfig = LT.serviceHarden;

  services.nginx.virtualHosts."prometheus.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
      "/".extraConfig =
        LT.nginx.locationOauthConf
        + ''
          proxy_pass http://127.0.0.1:${LT.portStr.Prometheus.Daemon};
        ''
        + LT.nginx.locationProxyConf;
    };
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
