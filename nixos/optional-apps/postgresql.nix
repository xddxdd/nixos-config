{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  isBtrfsOrVirtiofsRoot = builtins.elem (config.fileSystems."/nix".fsType or "") [
    "btrfs"
    "virtiofs"
  ];
in
{
  services.postgresql = {
    enable = true;
    enableJIT = true;
    package = pkgs.postgresql_18_jit;
    extensions =
      ps: with ps; [
        pgvector
        vectorchord
      ];
    authentication = ''
      host all all 198.18.0.0/15 md5
      host all all fdbc:f9dc:67ad::/48 md5
    '';
    settings = {
      listen_addresses = lib.mkForce (
        lib.concatStringsSep ", " [
          "127.0.0.1"
          "::1"
          LT.this.ltnet.IPv4
          LT.this.ltnet.IPv6
        ]
      );
      max_connections = "1000";
      io_method = "io_uring";
      idle_in_transaction_session_timeout = "0";
      idle_session_timeout = "0";
    }
    // (lib.optionalAttrs isBtrfsOrVirtiofsRoot {
      wal_init_zero = "off";
      wal_recycle = "off";
    });
  };

  systemd.services.postgresql.serviceConfig = LT.serviceHarden // {
    TimeoutStartSec = "900";
    LimitMEMLOCK = "infinity";
    LimitNOFILE = "1048576";
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    port = LT.port.Prometheus.PostgresExporter;
    listenAddress = LT.this.ltnet.IPv4;
    runAsLocalSuperUser = true;
  };
}
