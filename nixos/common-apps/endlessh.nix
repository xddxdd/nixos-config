{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  services.endlessh-go = {
    enable = true;
    port = 22;
    prometheus = {
      enable = true;
      port = LT.port.Prometheus.EndlesshGo;
      listenAddress = LT.this.ltnet.IPv4;
    };
    extraOptions = [
      "-geoip_supplier=max-mind-db"
      "-max_mind_db=/var/lib/GeoIP/GeoLite2-City.mmdb"
    ];
  };

  systemd.services.endlessh-go.serviceConfig.BindReadOnlyPaths = [
    "/var/lib/GeoIP"
  ];
}
