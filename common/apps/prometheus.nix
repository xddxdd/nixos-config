{ pkgs, config, ... }:

let
  LT = import ../helpers.nix { inherit config pkgs; };

  scrapeAllNodes = jobName: port: {
    job_name = jobName;
    static_configs = pkgs.lib.mapAttrsToList
      (n: v: {
        targets = [ "${v.ltnet.IPv4}:${builtins.toString port}" ];
        labels.instance = n;
      })
      LT.hosts;
  };
in
{
  services.prometheus = {
    enable = true;
    port = LT.port.Prometheus.Daemon;
    listenAddress = "127.0.0.1";
    stateDir = "prometheus";

    scrapeConfigs = [
      ({
        job_name = "prometheus";
        static_configs = [{
          targets = [ "${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}" ];
        }];
      })
      (scrapeAllNodes "node" LT.port.Prometheus.NodeExporter)
      (scrapeAllNodes "bird" LT.port.Prometheus.BirdExporter)
    ];
  };
}
