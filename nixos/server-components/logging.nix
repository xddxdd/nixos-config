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
          patches = (old.patches or [ ]) ++ [
            (pkgs.writeText "fluent-bit-down-chunk-ordering.patch" ''
              diff --git a/src/flb_input_chunk.c b/src/flb_input_chunk.c
              --- a/src/flb_input_chunk.c
              +++ b/src/flb_input_chunk.c
              @@ -2783,6 +2783,17 @@ static struct flb_input_chunk *input_chunk_get(struct flb_input_instance *in,
                       ic->event_type = event_type;
                   }
              ${" "}
              +    /* Creation may return a down chunk when the mmap budget is exhausted.
              +     * Read its metadata only after opening/mapping it, then let the caller
              +     * restore the down state after writing as it already does. */
              +    if (cio_chunk_is_up(ic->chunk) == CIO_FALSE) {
              +        ret = cio_chunk_up_force(ic->chunk);
              +        if (ret != CIO_OK) {
              +            return NULL;
              +        }
              +        *set_down = FLB_TRUE;
              +    }
              +
                   /*
                    * If buffering this block of data will exceed one of the limit among all output instances
                    * that the chunk will flush to, we need to modify the routes_mask of the oldest chunks
            '')
          ];
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

  systemd.services.fluent-bit = lib.mkIf config.services.fluent-bit.enable {
    # Run inside the mounted state directory, not before its host mount exists.
    preStart = ''
      ${pkgs.coreutils}/bin/install -d -m 0750 /var/lib/fluent-bit/storage
    '';
    serviceConfig = LT.serviceHarden // {
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
        "/etc/machine-id"
      ];
      # StateDirectory survives stops and is mounted through the confinement root.
      StateDirectory = "fluent-bit";
      StateDirectoryMode = "0750";
    };
  };
  lantian.harden.fluent-bit = true;

  users.users.fluent-bit = {
    isSystemUser = true;
    group = "fluent-bit";
  };
  users.groups.fluent-bit = { };
}
