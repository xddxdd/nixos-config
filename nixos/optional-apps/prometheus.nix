{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  scrapeAllNodes = jobName: port: {
    job_name = jobName;
    static_configs = lib.mapAttrsToList
      (n: v: {
        targets = [ "${v.ltnet.IPv4}:${builtins.toString port}" ];
        labels.instance = n;
      })
      LT.serverHosts;
  };
in
{
  services.prometheus = {
    enable = true;
    port = LT.port.Prometheus.Daemon;
    listenAddress = "127.0.0.1";
    stateDir = "prometheus";

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{
          targets = [ "${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}" ];
        }];
      }
      (scrapeAllNodes "bird" LT.port.Prometheus.BirdExporter)
      (scrapeAllNodes "endlessh-go" LT.port.Prometheus.EndlesshGo)
      (scrapeAllNodes "node" LT.port.Prometheus.NodeExporter)
    ];
  };

  systemd.services.prometheus.serviceConfig = LT.serviceHarden;
}
