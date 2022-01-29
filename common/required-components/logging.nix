{ config, pkgs, ... }:

{
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
              { equals."systemd.unit" = "resilio.service"; }
              { equals."systemd.unit" = "yggdrasil.service"; }
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

  services.journald.extraConfig = ''
    SystemMaxUse=50M
    SystemMaxFileSize=10M
  '';
}
