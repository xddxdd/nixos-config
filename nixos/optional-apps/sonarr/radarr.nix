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
      RestartSec = "5s";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      StateDirectory = "radarr";
      MemoryDenyWriteExecute = false;
      BindPaths = [ "/var/lib/radarr" ];
    };
    confinement = { enable = true; fullUnit = true; };
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
    # sonarr.localhost /etc/hosts entries are gone; use the loopback direct
    url = "http://127.0.0.1:${LT.portStr.Radarr}";
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
    RestartSec = "5s";
    # chroot's tmpfs root is ephemeral; bind data dir through
    BindReadOnlyPaths = [ "/var/lib/radarr" ];

    AmbientCapabilities = [ "" ];
    SystemCallErrorNumber = "EPERM";
  };
  lantian.harden."prometheus-exportarr-radarr-exporter" = true;
}
