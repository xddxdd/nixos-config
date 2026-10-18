{
  config,
  lib,
  LT,
  ...
}:
let
  dataDir = config.services.loki.dataDir;
  retention = "720h";
  httpSocket = "/run/loki/http.sock";
  proxyLocation = {
    proxyPass = "http://unix:${httpSocket}";
    proxyWebsockets = true;
    proxyNoTimeout = true;
  };
in
{
  services.loki = {
    enable = true;
    dataDir = "/var/lib/loki";
    configuration = {
      auth_enabled = false;
      target = "all";

      server = {
        log_level = "warn";
        http_listen_network = "unix";
        http_listen_address = httpSocket;
        http_listen_port = 0;
        grpc_listen_address = "127.0.0.1";
        register_instrumentation = true;
      };

      ruler.enable_api = false;

      common = {
        instance_addr = "127.0.0.1";
        path_prefix = dataDir;
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
        storage.filesystem = {
          chunks_directory = "${dataDir}/chunks";
          rules_directory = "${dataDir}/rules";
        };
      };

      schema_config.configs = [
        {
          from = "2020-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "loki_index_";
            period = "24h";
          };
        }
      ];

      storage_config.tsdb_shipper = {
        active_index_directory = "${dataDir}/tsdb-index";
        cache_location = "${dataDir}/tsdb-cache";
      };

      ingester = {
        # The sample-age limit permits 30-day backlog, but existing streams still
        # reject entries more than 24h behind their newest accepted timestamp.
        max_chunk_age = "48h";
        wal = {
          enabled = true;
          dir = "${dataDir}/wal";
        };
      };

      compactor = {
        working_directory = "${dataDir}/compactor";
        retention_enabled = true;
        delete_request_store = "filesystem";
        retention_delete_delay = "2h";
        retention_delete_worker_count = 10;
      };

      limits_config = {
        deletion_mode = "disabled";
        ingestion_rate_mb = 1000000;
        ingestion_burst_size_mb = 1000000;
        per_stream_rate_limit = "1TB";
        per_stream_rate_limit_burst = "1TB";
        retention_period = retention;
        max_query_lookback = retention;
        reject_old_samples = true;
        reject_old_samples_max_age = retention;
        unordered_writes = true;
      };
    };
  };

  # Keep upstream ProtectSystem=full and Restart=always; hardening defaults
  # must not replace upstream scalar settings with competing definitions.
  systemd.services.loki.serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
    Group = config.services.loki.group;
    RuntimeDirectory = "loki";
    RuntimeDirectoryMode = "0770";
    UMask = "0007";
    # chroot's tmpfs root is ephemeral; bind host state dir and socket
    # (read and proxied by nginx through its group membership)
    BindPaths = [
      "/var/lib/loki"
      "/run/loki"
    ];
  };

  systemd.services.loki.confinement = { enable = true; fullUnit = true; };

  users.groups.${config.services.loki.group}.members = [ config.services.nginx.user ];
  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ config.services.loki.group ];

  lantian.nginxVhosts.loki = {
    listenHTTP = {
      enable = true;
      port = LT.port.Loki;
      default = true;
    };
    listenHTTPS.enable = false;
    accessibleBy = "private";
    locations = lib.genAttrs [
      "= /loki/api/v1/push"
      "= /api/prom/push"
      "= /otlp/v1/logs"
      "= /loki/api/v1/query"
      "= /loki/api/v1/query_range"
      "= /loki/api/v1/label"
      "= /loki/api/v1/labels"
      "~ ^/loki/api/v1/label/[^/]+/values$"
      "= /loki/api/v1/series"
      "= /loki/api/v1/index/stats"
      "= /loki/api/v1/index/shards"
      "= /loki/api/v1/index/volume"
      "= /loki/api/v1/index/volume_range"
      "= /loki/api/v1/patterns"
      "= /loki/api/v1/detected_labels"
      "= /loki/api/v1/detected_fields"
      "~ ^/loki/api/v1/detected_field/[^/]+/values$"
      "= /api/prom/query"
      "= /api/prom/label"
      "~ ^/api/prom/label/[^/]+/values$"
      "= /api/prom/series"
      "= /loki/api/v1/tail"
      "= /api/prom/tail"
      "= /metrics"
    ] (_: proxyLocation);
  };

  # Loki has no authentication: accept its private endpoint only through the
  # LTnet mesh, the existing ZeroTier fallback, or local loopback traffic.
  lantian.firewall.chains.FILTER_INPUT.rules = [
    {
      priority = LT.firewallPriorities.preService;
      text = ''
        ip daddr ${LT.this.ltnet.IPv4} tcp dport ${LT.portStr.Loki} ip saddr != 198.18.0.0/24 reject with tcp reset
        ip daddr ${LT.this.ltnet.IPv4} tcp dport ${LT.portStr.Loki} iifname != "lo" iifname != "wgmesh*" iifname != "ztramij2dg" reject with tcp reset
      '';
    }
  ];
}
