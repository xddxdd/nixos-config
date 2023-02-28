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

  glauthUsers = import (inputs.secrets + "/glauth-users.nix");
in {
  services.prometheus = {
    enable = true;
    port = LT.port.Prometheus.Daemon;
    listenAddress = "127.0.0.1";
    stateDir = "prometheus";
    checkConfig = "syntax-only";

    alertmanagers = [
      {
        scheme = "http";
        static_configs = [
          {
            targets = [
              "localhost:${LT.portStr.Prometheus.AlertManager}"
            ];
          }
        ];
      }
    ];

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
      (scrapeAllNodes "node" LT.port.Prometheus.NodeExporter)
    ];

    # https://gist.github.com/globin/02496fd10a96a36f092a8e7ea0e6c7dd
    rules = [
      (builtins.toJSON {
        groups = [
          {
            name = "node_exporter";
            rules = [
              # # SystemD service
              # {
              #   alert = "node_systemd_service_failed";
              #   expr = ''node_systemd_unit_state{state="failed"} == 1'';
              #   for = "10m";
              #   labels.severity = "warning";
              #   annotations = {
              #     summary = "⚠️ {{$labels.alias}}: Service {{$labels.name}} failed to start.";
              #     description = "{{$labels.alias}} failed to (re)start service {{$labels.name}}.";
              #   };
              # }

              # Filesystem
              {
                alert = "node_filesystem_full_90percent";
                expr = ''sort(node_filesystem_free_bytes{mountpoint="/nix"} < node_filesystem_size_bytes{mountpoint="/nix"} * 0.1)'';
                for = "10m";
                labels.severity = "warning";
                annotations = {
                  summary = "⚠️ {{$labels.alias}}: Filesystem is running out of space soon.";
                  description = "{{$labels.alias}} device {{$labels.device}} on {{$labels.mountpoint}} got less than 10% space left on its filesystem.";
                };
              }
              {
                alert = "node_filesystem_readonly";
                expr = ''node_filesystem_readonly{mountpoint="/nix"} == 1'';
                for = "1m";
                labels.severity = "critical";
                annotations = {
                  summary = "⚠️ {{$labels.alias}}: Filesystem is readonly.";
                  description = "{{$labels.alias}} device {{$labels.device}} on {{$labels.mountpoint}} is readonly.";
                };
              }

              # # System Load
              # # Disable for spurius warnings
              # (rec {
              #   alert = "node_load1_90percent";
              #   expr = ''node_load1 / (count without(cpu, mode) (node_cpu_seconds_total{mode="idle",instance!~"servarica"})) >= 0.9'';
              #   for = "30m";
              #   labels.severity = "warning";
              #   annotations = {
              #     summary = "⚠️ {{$labels.alias}}: Running on high load.";
              #     description = "{{$labels.alias}} is running with > 90% total load for ${for}.";
              #   };
              # })

              # CPU usage
              # Exclude servarica for spurius warnings
              rec {
                alert = "node_cpu_util_90percent";
                expr = ''1 - avg by (instance) (irate(node_cpu_seconds_total{mode="idle",instance!~"servarica"}[5m])) >= 0.9'';
                for = "30m";
                labels.severity = "warning";
                annotations = {
                  summary = "⚠️ {{$labels.alias}}: High CPU utilization.";
                  description = "{{$labels.alias}} has total CPU utilization over 90% for ${for}.";
                };
              }

              # RAM usage
              rec {
                alert = "node_ram_using_90percent";
                expr = ''node_memory_MemFree_bytes + node_memory_Buffers_bytes + node_memory_Cached_bytes < node_memory_MemTotal_bytes * 0.1'';
                for = "30m";
                labels.severity = "warning";
                annotations = {
                  summary = "⚠️ {{$labels.alias}}: Using lots of RAM.";
                  description = "{{$labels.alias}} is using at least 90% of its RAM for ${for}.";
                };
              }
            ];
          }
        ];
      })
    ];
  };

  services.prometheus.alertmanager = {
    enable = true;
    port = LT.port.Prometheus.AlertManager;
    listenAddress = "127.0.0.1";
    configuration = {
      global = {
        smtp_from = config.programs.msmtp.accounts.default.from;
        smtp_smarthost =
          config.programs.msmtp.accounts.default.host
          + ":"
          + builtins.toString config.programs.msmtp.accounts.default.port;
        smtp_auth_username = config.programs.msmtp.accounts.default.user;
        smtp_auth_password = {_secret = config.age.secrets.smtp-pass.path;};
        smtp_require_tls = config.programs.msmtp.accounts.default.tls_starttls;
      };
      route = {
        group_by = ["alertname" "alias"];
        group_wait = "30s";
        group_interval = "2m";
        repeat_interval = "4h";
        receiver = "admin";
      };
      receivers = [
        {
          "name" = "admin";
          "email_configs" = [
            {
              "to" = glauthUsers.lantian.mail;
              "send_resolved" = true;
            }
          ];
        }
      ];
    };
  };

  systemd.services.prometheus.serviceConfig = LT.serviceHarden;

  systemd.services.alertmanager = {
    preStart = lib.mkForce ''
      ${utils.genJqSecretsReplacementSnippet
        config.services.prometheus.alertmanager.configuration
        "/tmp/alert-manager-substituted.yaml"}
    '';
  };
}
