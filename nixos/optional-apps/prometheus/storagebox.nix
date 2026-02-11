{
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets.hetzner-storagebox-metrics-token = {
    file = inputs.secrets + "/hetzner-storagebox-metrics-token.age";
    owner = config.services.prometheus.exporters.storagebox.user;
    inherit (config.services.prometheus.exporters.storagebox) group;
  };

  services.prometheus.exporters.storagebox = {
    enable = true;
    port = LT.port.Prometheus.StorageBoxExporter;
    listenAddress = "127.0.0.1";
    tokenFile = config.age.secrets.hetzner-storagebox-metrics-token.path;
  };

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
