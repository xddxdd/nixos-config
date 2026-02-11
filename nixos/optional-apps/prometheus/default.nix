{
  lib,
  LT,
  config,
  ...
}:
let
  _hostsWithAttrEnabled =
    attrPath:
    builtins.attrNames (
      lib.filterAttrs (
        n: v:
        # Disable crawling client nodes
        !LT.hosts."${n}".hasTag LT.tags.client
        # Check if attr is enabled
        && lib.attrByPath attrPath false v.config
      ) LT.self.nixosConfigurations
    );

  scrapeByAttr =
    {
      jobName,
      index ? null,
      port,
      attrPath,
      metricsPath ? "/metrics",
    }:
    {
      job_name = jobName;
      metrics_path = metricsPath;
      static_configs = builtins.map (
        n:
        let
          targetIP =
            if index == null then
              "${LT.hosts."${n}".ltnet.IPv4}"
            else
              "${LT.hosts."${n}".ltnet.IPv4Prefix}.${builtins.toString index}";
        in
        {
          targets = [
            "${targetIP}:${builtins.toString port}"
          ];
          labels.job = jobName;
          labels.instance = n;
        }
      ) (_hostsWithAttrEnabled attrPath);
    };
in
{
  imports = [
    ./alertmanager.nix
    ./blackbox-exporter.nix
    ./periodic-tasks.nix
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
      (scrapeByAttr {
        jobName = "bird";
        port = LT.port.Prometheus.BirdExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "bird"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "mysql";
        port = LT.port.Prometheus.MySQLExporter;
        attrPath = [
          "systemd"
          "services"
          "prometheus-mysqld-exporter"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "node";
        port = LT.port.Prometheus.NodeExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "node"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "postgres";
        port = LT.port.Prometheus.PostgresExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "postgres"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "coredns";
        index = 56;
        port = LT.port.Prometheus.CoreDNS;
        attrPath = [
          "systemd"
          "services"
          "coredns"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "coredns-authoritative";
        index = 54;
        port = LT.port.Prometheus.CoreDNS;
        attrPath = [
          "systemd"
          "services"
          "coredns-authoritative"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "rasdaemon";
        port = LT.port.Prometheus.RasdaemonExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "rasdaemon"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "smartctl";
        port = LT.port.Prometheus.SmartctlExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "smartctl"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "wireguard";
        port = LT.port.Prometheus.WireGuardExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "wireguard"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "nut";
        port = LT.port.Prometheus.NUTExporter;
        metricsPath = "/ups_metrics";
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "nut"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "nut-exporter";
        port = LT.port.Prometheus.NUTExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "nut"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "sonarr";
        port = LT.port.Prometheus.SonarrExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "exportarr-sonarr"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "radarr";
        port = LT.port.Prometheus.SonarrExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "exportarr-radarr"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "prowlarr";
        port = LT.port.Prometheus.SonarrExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "exportarr-prowlarr"
          "enable"
        ];
      })
      (scrapeByAttr {
        jobName = "bazarr";
        port = LT.port.Prometheus.SonarrExporter;
        attrPath = [
          "services"
          "prometheus"
          "exporters"
          "exportarr-bazarr"
          "enable"
        ];
      })
      {
        job_name = "sglang-sakura-llm";
        scheme = "https";
        static_configs = [
          { targets = [ "sakura-llm.lt-home-rdp.xuyh0120.win" ]; }
        ];
      }
      {
        job_name = "sakura-share";
        scheme = "https";
        static_configs = [
          { targets = [ "sakura-share.one" ]; }
        ];
      }
      {
        job_name = "flapalerted";
        scheme = "https";
        metrics_path = "/flaps/metrics/prometheus";
        static_configs = [
          { targets = [ "flapalerted.lantian.pub" ]; }
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

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
  };
}
