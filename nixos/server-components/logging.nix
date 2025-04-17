{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets.filebeat-elasticsearch-pw.file = inputs.secrets + "/filebeat-elasticsearch-pw.age";

  services.filebeat = {
    enable = !(LT.this.hasTag LT.tags.low-ram);
    package = pkgs.filebeat8;
    inputs = {
      journald = {
        type = "journald";
        id = "everything";
        processors = [
          {
            drop_event.when.or = [
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
      output.elasticsearch = {
        hosts = [ "https://cloud.community.humio.com:9200" ];
        username = "any-organization";
        password = {
          _secret = config.age.secrets.filebeat-elasticsearch-pw.path;
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
    serviceConfig = LT.serviceHarden // {
      ProcSubset = "all";
      ReadOnlyPaths = [ "/run" ];
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
    };
  };
}
