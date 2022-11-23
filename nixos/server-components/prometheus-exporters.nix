{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
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
