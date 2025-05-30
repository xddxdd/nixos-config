{
  pkgs,
  LT,
  config,
  ...
}:
let
  blackboxExporterHost = "${config.services.prometheus.exporters.blackbox.listenAddress}:${builtins.toString config.services.prometheus.exporters.blackbox.port}";

  httpMonitorTargets = [
    # Doesn't include main blog as that's monitored by UptimeRobot

    # 3rd party backup hostings for main blog
    "https://github-pages.lantian.pub"
    "https://netlify.lantian.pub"
    "https://render.lantian.pub"
    "https://vercel.lantian.pub"

    # SSL tests
    "https://buypass-ssl.lantian.pub"
    "https://letsencrypt-ssl.lantian.pub"
    "https://zerossl.lantian.pub"

    # Services exposed to external users
    "https://comments.lantian.pub"
    "https://git.lantian.pub"
    "https://lab.lantian.pub"
    "https://lab.xuyh0120.win"
    "https://lemmy.lantian.pub"
    "https://lg.lantian.pub"
    "https://matrix.lantian.pub"
    "https://tools.lantian.pub"
    "https://whois.lantian.pub"

    # Services for myself
    "https://alert.xuyh0120.win"
    "https://asf.xuyh0120.win"
    "https://attic.xuyh0120.win"
    # "https://books.xuyh0120.win"
    "https://bitwarden.xuyh0120.win"
    # "https://cal.xuyh0120.win"
    "https://dashboard.xuyh0120.win"
    "https://jellyfin.xuyh0120.win"
    "https://netbox.xuyh0120.win"
    "https://prometheus.xuyh0120.win"
    # "https://pterodactyl.xuyh0120.win"
    "https://rss.xuyh0120.win"
    "https://rsshub.xuyh0120.win"
    "https://stats.xuyh0120.win"
    # "https://tachidesk.xuyh0120.win"
  ];
in
{
  services.prometheus.exporters.blackbox = {
    enable = true;
    port = LT.port.Prometheus.BlackboxExporter;
    listenAddress = "127.0.0.1";
    configFile = pkgs.writeText "config.yaml" (
      builtins.toJSON {
        modules = {
          https_2xx = {
            prober = "http";
            timeout = "15s";
            http.fail_if_not_ssl = true;
          };
        };
      }
    );
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "blackbox_exporter";
      static_configs = [ { targets = [ blackboxExporterHost ]; } ];
    }
    {
      job_name = "https_2xx";
      scrape_interval = "1m";
      metrics_path = "/probe";
      params.module = [ "https_2xx" ];
      static_configs = [ { targets = httpMonitorTargets; } ];
      relabel_configs = [
        {
          source_labels = [ "__address__" ];
          target_label = "__param_target";
        }
        {
          source_labels = [ "__param_target" ];
          target_label = "instance";
        }
        {
          target_label = "__address__";
          replacement = blackboxExporterHost;
        }
      ];
    }
  ];

  services.prometheus.rules = [
    (builtins.toJSON {
      groups = [
        {
          name = "https_2xx";
          rules = [
            {
              alert = "https_2xx_web_service_failed";
              expr = ''probe_success{job="https_2xx"} == 0'';
              for = "15m";
              labels.severity = "warning";
              annotations = {
                summary = "⚠️ {{$labels.alias}}: Web service {{$labels.name}} failed.";
                description = "{{$labels.alias}} is not returning status code 200 for {{$labels.name}}.";
              };
            }
          ];
        }
      ];
    })
  ];
}
