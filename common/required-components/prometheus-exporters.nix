{ config, pkgs, ... }:

let
  LT = import ../helpers.nix { inherit config pkgs; };
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
