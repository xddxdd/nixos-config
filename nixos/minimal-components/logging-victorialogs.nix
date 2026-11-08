{
  lib,
  LT,
  config,
  pkgs,
  ...
}:
{
  services.fluent-bit = {
    enable = !(LT.this.hasTag LT.tags.client);
    # libsystemd needs compression support to read Zstd-compressed journals.
    package =
      (pkgs.fluent-bit.override {
        systemdLibs = pkgs.systemdLibs.override { withCompression = true; };
      }).overrideAttrs
        (old: {
          patches = (old.patches or [ ]) ++ [ ../../patches/fluent-bit-down-chunk-ordering.patch ];
        });
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
        outputs = [
          {
            name = "http";
            match = "journal";
            host = LT.hosts.colocrossing.ltnet.IPv4;
            port = LT.port.VictoriaLogs;
            tls = "off";
            # 在请求中补充固定字段，已有磁盘队列也能保留主机和日志类型。
            uri = "/insert/jsonline?_stream_fields=job,host,_SYSTEMD_UNIT&_msg_field=MESSAGE&_time_field=date&extra_fields=job=journal,host=${config.networking.hostName}";
            format = "json_lines";
            json_date_key = "date";
            json_date_format = "iso8601";
            compress = "gzip";
            "storage.total_limit_size" = "256M";
            retry_limit = "no_limits";
          }
        ];
      };
    };
  };

  # Directory audit filters must exist before audit-rules-nixos loads them.
  systemd.tmpfiles.settings.fluent-bit = lib.mkIf config.services.fluent-bit.enable {
    "/var/lib/fluent-bit".d = {
      mode = "0750";
      user = "fluent-bit";
      group = "fluent-bit";
    };
  };

  systemd.services.fluent-bit = lib.mkIf config.services.fluent-bit.enable {
    # Run inside the mounted state directory, not before its host mount exists.
    preStart = ''
      ${pkgs.coreutils}/bin/install -d -m 0750 /var/lib/fluent-bit/storage
    '';
    serviceConfig = {
      RestartSec = "5s";
      ProcSubset = "all";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
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
      ];
      # StateDirectory survives stops and is mounted through the confinement root.
      StateDirectory = "fluent-bit";
      StateDirectoryMode = "0750";
    };
  };
  lantian.harden.fluent-bit = {
    enable = config.services.fluent-bit.enable;
    enableConfinement = config.services.fluent-bit.enable;
  };

  users.users.fluent-bit = lib.mkIf config.services.fluent-bit.enable {
    isSystemUser = true;
    group = "fluent-bit";
  };
  users.groups.fluent-bit = lib.mkIf config.services.fluent-bit.enable { };
}
