{
  pkgs,
  lib,
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
    "https://letsencrypt-ssl.lantian.pub"
    "https://zerossl.lantian.pub"

    # Services under lantian.pub
    "https://comments.lantian.pub"
    "https://element.lantian.pub"
    "https://flapalerted.lantian.pub"
    "https://git.lantian.pub"
    "https://lab.lantian.pub"
    "https://lemmy.lantian.pub"
    "https://lg.lantian.pub"
    "https://login.lantian.pub"
    "https://matrix.lantian.pub/_matrix/client/versions"
    "https://sip.lantian.pub"
    "https://tools.lantian.pub"
    "https://whois.lantian.pub"

    # Services under xuyh0120.win
    "https://ai.xuyh0120.win"
    "https://alert.xuyh0120.win"
    "https://asf.xuyh0120.win"
    "https://attic.xuyh0120.win"
    # "https://books.xuyh0120.win"
    "https://bitwarden.xuyh0120.win"
    "https://cal.xuyh0120.win"
    "https://dashboard.xuyh0120.win"
    "https://jellyfin.xuyh0120.win"
    "https://lab.xuyh0120.win"
    "https://netbox.xuyh0120.win"
    "https://prometheus.xuyh0120.win"
    "https://rss.xuyh0120.win"
    "https://rsshub.xuyh0120.win"
    "https://searx.xuyh0120.win"
    "https://stats.xuyh0120.win"
    # "https://tachidesk.xuyh0120.win"
  ];

  monitoredHosts = lib.filterAttrs (
    n: v: v.hasTag LT.tags.server && v.hasTag LT.tags.public-facing
  ) LT.hosts;

  # Cannot monitor self due to hairpin NAT issue
  monitoredHostsExceptSelf = lib.filterAttrs (n: v: n != config.networking.hostName) monitoredHosts;

  httpPublicFacingHosts = lib.mapAttrsToList (n: v: "https://${n}.lantian.pub") monitoredHosts;

  publicFacingHostsExceptSelf =
    port:
    lib.mapAttrsToList (
      n: v: "${n}.lantian.pub" + lib.optionalString (port != null) ":${builtins.toString port}"
    ) monitoredHostsExceptSelf;

  relabelConfigs = [
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
          dns = {
            prober = "dns";
            timeout = "15s";
            dns = {
              query_name = "lantian.dn42";
              query_type = "A";
              validate_authority_rrs.fail_if_none_matches_regexp = [
                "\\.lantian\\.dn42\\.$"
              ];
            };
          };
          gopher = {
            prober = "tcp";
            timeout = "15s";
            tcp.query_response = [
              { send = "/\r\n"; }
              { expect = "gopher\\.lantian\\."; }
            ];
          };
          whois = {
            prober = "tcp";
            timeout = "15s";
            tcp.query_response = [
              { send = "AS4242422547\r\n"; }
              { expect = "LANTIAN-DN42"; }
            ];
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
      static_configs = [ { targets = httpMonitorTargets ++ httpPublicFacingHosts; } ];
      relabel_configs = relabelConfigs;
    }
    {
      job_name = "dns";
      scrape_interval = "1m";
      metrics_path = "/probe";
      params.module = [ "dns" ];
      static_configs = [ { targets = publicFacingHostsExceptSelf null; } ];
      relabel_configs = relabelConfigs;
    }
    {
      job_name = "gopher";
      scrape_interval = "1m";
      metrics_path = "/probe";
      params.module = [ "gopher" ];
      static_configs = [ { targets = publicFacingHostsExceptSelf 70; } ];
      relabel_configs = relabelConfigs;
    }
    {
      job_name = "whois";
      scrape_interval = "1m";
      metrics_path = "/probe";
      params.module = [ "whois" ];
      static_configs = [ { targets = publicFacingHostsExceptSelf 43; } ];
      relabel_configs = relabelConfigs;
    }
  ];

  services.prometheus.ruleFiles = [
    (pkgs.writeText "blackbox-exporter.rules" (
      builtins.toJSON {
        groups = [
          {
            name = "blackbox_exporter";
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
              {
                alert = "dns_service_failed";
                expr = ''probe_success{job="dns"} == 0'';
                for = "15m";
                labels.severity = "warning";
                annotations = {
                  summary = "⚠️ {{$labels.alias}}: DNS service {{$labels.name}} failed.";
                  description = "{{$labels.alias}} is not returning DNS response for {{$labels.name}}.";
                };
              }
              {
                alert = "gopher_service_failed";
                expr = ''probe_success{job="gopher"} == 0'';
                for = "15m";
                labels.severity = "warning";
                annotations = {
                  summary = "⚠️ {{$labels.alias}}: Gopher service {{$labels.name}} failed.";
                  description = "{{$labels.alias}} is not returning Gopher response for {{$labels.name}}.";
                };
              }
              {
                alert = "whois_service_failed";
                expr = ''probe_success{job="whois"} == 0'';
                for = "15m";
                labels.severity = "warning";
                annotations = {
                  summary = "⚠️ {{$labels.alias}}: WHOIS service {{$labels.name}} failed.";
                  description = "{{$labels.alias}} is not returning WHOIS response for {{$labels.name}}.";
                };
              }
            ];
          }
        ];
      }
    ))
  ];
}
