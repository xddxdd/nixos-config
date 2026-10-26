{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  sops.secrets.filebeat-humio-token = {
    sopsFile = inputs.secrets + "/common/filebeat.yaml";
    restartUnits = lib.optional config.services.filebeat.enable "filebeat.service";
  };

  services.filebeat = {
    enable = !(LT.this.hasTag LT.tags.low-ram);
    package = pkgs.filebeat8;
    inputs = {
      journald = {
        type = "journald";
        id = "everything";
        processors = [
          {
            drop_event.when."or" = [
              { equals."systemd.unit" = "filebeat.service"; }
              { equals."systemd.unit" = "hath.service"; }
              { equals."systemd.unit" = "matrix-synapse.service"; }
              { equals."systemd.unit" = "podman-archiveteam.service"; }
              { equals."systemd.unit" = "prowlarr.service"; }
              { equals."systemd.unit" = "radarr.service"; }
              { equals."systemd.unit" = "resilio.service"; }
              { equals."systemd.unit" = "sonarr.service"; }
              { equals."systemd.unit" = "yggdrasil.service"; }
            ];
          }
        ];
      };
    };
    settings = {
      logging.level = "warning";
      http = {
        enabled = true;
        host = "unix:///var/lib/filebeat/monitoring.sock";
      };
      output.elasticsearch = {
        hosts = [ "https://cloud.community.humio.com:9200" ];
        username = "any-organization";
        password = {
          _secret = config.sops.secrets.filebeat-humio-token.path;
        };
        compression_level = 6;
        index = "beat";
      };
      setup.template = {
        name = "beat";
        pattern = "beat";
      };
    };
  };

  systemd.services.filebeat = lib.mkIf config.services.filebeat.enable {
    # Filebeat's journald input invokes journalctl by name.
    path = [ pkgs.systemd ];
    serviceConfig = {
      RestartSec = "5s";
      ProcSubset = "all";
      ReadOnlyPaths = [ "/run" ];
      BindReadOnlyPaths = [ "/var/log/journal" ];
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
    };
  };
  lantian.harden.filebeat = {
    enable = config.services.filebeat.enable;
    secret = true;
    etc."os-release" = true;
  };
}
