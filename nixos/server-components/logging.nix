{
  lib,
  LT,
  config,
  pkgs,
  ...
}:
{
  services.fluent-bit = {
    enable = !(LT.this.hasTag LT.tags.low-ram);
    # libsystemd needs compression support to read Zstd-compressed journals.
    package = pkgs.fluent-bit.override {
      systemdLibs = pkgs.systemdLibs.override { withCompression = true; };
    };
    settings = {
      service = {
        flush = 5;
        log_level = "warn";
        "storage.path" = "/var/lib/fluent-bit/storage";
        "storage.sync" = "normal";
        "storage.checksum" = "on";
        "storage.max_chunks_up" = 8;
        "storage.backlog.mem_limit" = "8M";
      };
      pipeline = {
        inputs = [
          {
            name = "systemd";
            tag = "journal";
            db = "/var/lib/fluent-bit/journal.db";
            "db.sync" = "normal";
            lowercase = "off";
            strip_underscores = "off";
            "storage.type" = "filesystem";
          }
        ];
        filters = [
          {
            name = "grep";
            match = "journal";
            exclude = "_SYSTEMD_UNIT ^(filebeat|hath|matrix-synapse|podman-archiveteam|prowlarr|radarr|resilio|sonarr|yggdrasil|fluent-bit)\\.service$";
          }
          {
            name = "modify";
            match = "journal";
            # Fluent Bit 5.1's Loki output plugin removes label source keys; copy to retain _SYSTEMD_UNIT.
            copy = "_SYSTEMD_UNIT fluentbit_unit";
          }
        ];
        outputs = [
          {
            name = "loki";
            match = "journal";
            host = LT.hosts.colocrossing.ltnet.IPv4;
            port = LT.port.Loki;
            tls = "off";
            labels = "job=journal,host=${config.networking.hostName},unit=$fluentbit_unit";
            line_format = "json";
            drop_single_key = "off";
            compress = "gzip";
            "storage.total_limit_size" = "256M";
            retry_limit = "no_limits";
          }
        ];
      };
    };
  };

  systemd.services.fluent-bit = lib.mkIf config.services.fluent-bit.enable {
    serviceConfig = LT.serviceHarden // {
      RestartSec = "5s";
      ProcSubset = "all";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      # Reads journald files; chroot tmpfs root is ephemeral, so bind the
      # host state dir through
      # Fixed user instead of upstream DynamicUser: with the confinement
      # chroot + user namespace, host-side files land as nobody:nogroup and
      # are unwritable
      DynamicUser = lib.mkForce false;
      User = "fluent-bit";
      Group = "fluent-bit";
      PrivateUsers = false;
      BindReadOnlyPaths = [
        "/var/log/journal"
        "/run/log/journal"
        "/run/systemd/journal"
        "/etc/machine-id"
      ];
      BindPaths = [ "/var/lib/fluent-bit" ];
    };

    confinement = { enable = true; fullUnit = true; };
  };

  # State dir is bind-mounted through the confinement chroot; create it on
  # fresh hosts (can't use preservation, /var/lib is already preserved);
  # R rule fixes ownership of files previously created under a user namespace
  systemd.tmpfiles.settings = {
    fluent-bit = {
      "/var/lib/fluent-bit"."d" = {
        mode = "750";
        user = "fluent-bit";
        group = "fluent-bit";
      };
      "/var/lib/fluent-bit"."R" = {
        user = "fluent-bit";
        group = "fluent-bit";
      };
    };
  };

  users.users.fluent-bit = {
    isSystemUser = true;
    group = "fluent-bit";
  };
  users.groups.fluent-bit = { };
}
