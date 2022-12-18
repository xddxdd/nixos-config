{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  services.prometheus.exporters = {
    node = {
      enable = true;
      port = LT.port.Prometheus.NodeExporter;
      listenAddress = LT.this.ltnet.IPv4;
      enabledCollectors = [ "systemd" ];
    };
  };
}
