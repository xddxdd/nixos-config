{
  LT,
  config,
  lib,
  ...
}:
{
  services.radarr = {
    enable = true;
    user = "lantian";
    group = "users";
    dataDir = "/var/lib/radarr";
  };
  systemd.services.radarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      StateDirectory = "radarr";
      MemoryDenyWriteExecute = false;
    };
  };

  lantian.localVhosts.radarr = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Radarr}";
      };
    };
  };

  services.prometheus.exporters.exportarr-radarr = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.RadarrExporter;
    url = "http://radarr.localhost";
    environment = {
      INTERFACE = LT.this.ltnet.IPv4;
      PORT = LT.portStr.Prometheus.RadarrExporter;
      CONFIG = "/var/lib/radarr/config.xml";
      LOG_LEVEL = "warn";
    };
    inherit (config.services.radarr) user group;
  };
  systemd.services.prometheus-exportarr-radarr-exporter.serviceConfig = {
    DynamicUser = lib.mkForce false;
  };
}
