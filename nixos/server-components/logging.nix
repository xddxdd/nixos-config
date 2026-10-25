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
        filters = [
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

  systemd.services.fluent-bit = {
    # Run inside the mounted state directory, not before its host mount exists.
    preStart = lib.mkIf config.services.fluent-bit.enable ''
      ${pkgs.coreutils}/bin/install -d -m 0750 /var/lib/fluent-bit/storage
    '';
    serviceConfig = lib.mkIf config.services.fluent-bit.enable {
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
    enableConfinement = true;
  };

  users.users.fluent-bit = {
    isSystemUser = true;
    group = "fluent-bit";
  };
  users.groups.fluent-bit = { };
}
