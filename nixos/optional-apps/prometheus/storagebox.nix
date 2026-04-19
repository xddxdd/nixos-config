{
  LT,
  config,
  inputs,
  lib,
  ...
}:
{
  sops.secrets.hetzner-storagebox-metrics-token = {
    sopsFile = inputs.secrets + "/hetzner-storagebox-metrics.yaml";
    owner = config.services.prometheus.exporters.storagebox.user;
    inherit (config.services.prometheus.exporters.storagebox) group;
  };

  services.prometheus.exporters.storagebox = {
    enable = true;
    port = LT.port.Prometheus.StorageBoxExporter;
    listenAddress = "127.0.0.1";
    tokenFile = config.sops.secrets.hetzner-storagebox-metrics-token.path;
  };
  systemd.services.prometheus-storagebox-exporter.serviceConfig = {
    DynamicUser = lib.mkForce false;
  };
  users.users.storagebox-exporter = {
    group = "storagebox-exporter";
    isSystemUser = true;
  };
  users.groups.storagebox-exporter = { };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "storagebox_exporter";
      static_configs = [
        {
          targets = [ "127.0.0.1:${builtins.toString config.services.prometheus.exporters.storagebox.port}" ];
        }
      ];
    }
  ];
}
