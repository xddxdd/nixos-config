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

  systemd.services.postgresql.serviceConfig = {
    TimeoutStartSec = "900";
    LimitMEMLOCK = "infinity";
    LimitNOFILE = "1048576";
    RestartSec = "5s";
    # Keep consumers' bound socket-directory inode valid across stops and restarts.
    RuntimeDirectoryPreserve = true;
    # Postgres resolves peer-socket credentials with host uid→name mapping;
    # a user namespace would make that unmapped and break peer auth
    PrivateUsers = false;
    # chroot's tmpfs root is ephemeral; bind data dir + unix socket through;
    # the socket is accessed by exporters and apps outside the chroot
    BindPaths = [
      "/var/lib/postgresql"
      "/run/postgresql"
    ];
  };
  lantian.harden.postgresql = {
    enable = true;
    # Peer auth resolves peer uid→name via nss files.
    passwd = true;
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    port = LT.port.Prometheus.PostgresExporter;
    listenAddress = LT.this.ltnet.IPv4;
    runAsLocalSuperUser = true;
  };

  systemd.services."prometheus-postgres-exporter" = {
    # A same-UID exporter thread can reuse a stale postmaster PID after boot.
    # Stop it before PostgreSQL restarts, and start it only after PostgreSQL is ready.
    requires = [ "postgresql.service" ];
    partOf = [ "postgresql.service" ];
    serviceConfig = {
      RestartSec = "5s";
      ProcSubset = "all";
      ProtectProc = "default";
    };
  };
  lantian.harden.prometheus-postgres-exporter = {
    enable = true;
    postgresql = true;
  };
}
