{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  age.secrets.filebeat-elasticsearch-pw.file = inputs.secrets + "/filebeat-elasticsearch-pw.age";

  services.filebeat = {
    enable = true;
    package = pkgs.filebeat7;
    inputs = {
      journald = {
        type = "journald";
        id = "everything";
        processors = [
          {
            drop_event.when.or = [
              { equals."systemd.unit" = "filebeat.service"; }
              { equals."systemd.unit" = "matrix-synapse.service"; }
              { equals."systemd.unit" = "prowlarr.service"; }
              { equals."systemd.unit" = "radarr.service"; }
              { equals."systemd.unit" = "sonarr.service"; }
            ];
          }
        ];
      };
    };
    settings = {
      output.elasticsearch = {
        hosts = [ "https://cloud.community.humio.com:9200" ];
        username = "any-organization";
        password = { _secret = config.age.secrets.filebeat-elasticsearch-pw.path; };
        compression_level = 6;
        index = "beat";
      };
      setup.template = {
        name = "beat";
        pattern = "beat";
      };
    };
  };

  systemd.services.filebeat.serviceConfig = LT.serviceHarden // {
    ProcSubset = "all";
    ReadOnlyPaths = [
      "/run"
    ];
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
  };
}
