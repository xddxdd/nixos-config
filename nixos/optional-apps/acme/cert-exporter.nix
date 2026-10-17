{ LT, ... }:
{
  services.prometheus.exporters.node-cert = {
    enable = true;
    port = LT.port.Prometheus.NodeCertExporter;
    listenAddress = LT.this.ltnet.IPv4;
    paths = [ ];
    includeGlobs = [ "/nix/sync-servers/acme/*/cert.pem" ];
  };

  systemd.services."prometheus-node-cert-exporter".serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
  };
}
