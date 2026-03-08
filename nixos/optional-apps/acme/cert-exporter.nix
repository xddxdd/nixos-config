{ LT, ... }:
{
  services.prometheus.exporters.node-cert = {
    enable = true;
    port = LT.port.Prometheus.NodeCertExporter;
    listenAddress = LT.this.ltnet.IPv4;
    paths = [ "/nix/sync-servers/acme" ];
  };
}
