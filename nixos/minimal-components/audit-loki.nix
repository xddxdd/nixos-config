{
  config,
  lib,
  LT,
  pkgs,
  ...
}:
let
  package = pkgs.fluent-bit.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../../patches/fluent-bit-down-chunk-ordering.patch ];
  });
  configuration = (pkgs.formats.yaml { }).generate "audit-loki.yaml" {
    service = {
      flush = 5;
      log_level = "error";
      # Do not feed diagnostic/retry messages into the journal reader, whose
      # own persistent I/O would produce new audit events.
      log_file = "/run/audit-loki/forwarder.log";
      "storage.path" = "/var/lib/audit-loki/storage";
      "storage.sync" = "normal";
      "storage.checksum" = "on";
      "storage.max_chunks_up" = 8;
      "storage.backlog.mem_limit" = "4M";
    };
    pipeline = {
      inputs = [
        {
          name = "tail";
          tag = "audit";
          path = "/var/log/audit/audit.log*";
          path_key = "source";
          db = "/var/lib/audit-loki/offsets.db";
          "db.sync" = "normal";
          read_from_head = true;
          refresh_interval = 5;
          rotate_wait = 30;
          buffer_max_size = "1M";
          "storage.type" = "filesystem";
        }
      ];
      outputs = [
        {
          name = "loki";
          match = "audit";
          host = LT.hosts.colocrossing.ltnet.IPv4;
          port = LT.port.Loki;
          tls = "off";
          labels = "job=audit,host=${config.networking.hostName}";
          line_format = "json";
          compress = "gzip";
          "storage.total_limit_size" = "64M";
          retry_limit = "no_limits";
        }
      ];
    };
  };
in
{
  config = lib.mkIf config.security.auditd.enable {
    systemd.services.audit-loki = {
      description = "Stream native audit records directly to Loki";
      wantedBy = [ "multi-user.target" ];
      after = [
        "auditd.service"
        "network-online.target"
      ];
      wants = [
        "auditd.service"
        "network-online.target"
      ];
      preStart = ''
        # Fail closed if a static name collision defeats DynamicUser allocation.
        test "$(${pkgs.coreutils}/bin/id -u)" -gt 999
        ${pkgs.coreutils}/bin/mkdir -p /var/lib/audit-loki/storage
      '';
      serviceConfig = LT.serviceHarden // {
        ExecStart = "${lib.getExe package} --config ${configuration}";
        Restart = "on-failure";
        RestartSec = "10s";
        DynamicUser = true;
        User = "audit-loki";
        Group = "audit-loki";
        PrivateUsers = false;
        # Read the root-private audit trail, but only inside the whitelisted root.
        AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];
        CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];
        StateDirectory = "audit-loki";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "audit-loki";
        RuntimeDirectoryMode = "0700";
        BindReadOnlyPaths = [ "/var/log/audit" ];
        # Raw library stderr must not re-enter the journal pipeline either.
        StandardOutput = "null";
        StandardError = "null";
      };
    };
    lantian.harden.audit-loki = true;
    services.logrotate.settings.audit-loki = {
      files = [ "/run/audit-loki/forwarder.log" ];
      frequency = "hourly";
      maxsize = "1M";
      rotate = 1;
      copytruncate = true;
      missingok = true;
      notifempty = true;
    };
  };
}
