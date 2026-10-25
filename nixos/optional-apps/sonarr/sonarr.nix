{
  LT,
  config,
  lib,
  ...
}:
{
  services.sonarr = {
    enable = true;
    user = "lantian";
    group = "users";
    dataDir = "/var/lib/sonarr";
  };
  systemd.services.sonarr = {
    serviceConfig = {
      RestartSec = "5s";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      StateDirectory = "sonarr";
      MemoryDenyWriteExecute = false;
      BindPaths = [ "/var/lib/sonarr" ];
    };
  };
  lantian.harden.sonarr = {
    enable = true;
    passwd = true;
    etc = {
      "resolv.conf" = true;
      "ssl/certs/ca-certificates.crt" = true;
      "ssl/certs/ca-bundle.crt" = config.environment.etc."ssl/certs/ca-certificates.crt".source;
    };
  };

  lantian.localVhosts.sonarr = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Sonarr}";
      };
    };
  };

  services.prometheus.exporters.exportarr-sonarr = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.SonarrExporter;
    # sonarr.localhost /etc/hosts entries are gone; use the loopback direct
    url = "http://127.0.0.1:${LT.portStr.Sonarr}";
    environment = {
      INTERFACE = LT.this.ltnet.IPv4;
      PORT = LT.portStr.Prometheus.SonarrExporter;
      CONFIG = "/var/lib/sonarr/config.xml";
      LOG_LEVEL = "warn";
    };
    inherit (config.services.sonarr) user group;
  };
  systemd.services.prometheus-exportarr-sonarr-exporter.serviceConfig = {
    DynamicUser = lib.mkForce false;
    RestartSec = "5s";
    # chroot's tmpfs root is ephemeral; bind data dir through
    BindReadOnlyPaths = [ "/var/lib/sonarr" ];

    AmbientCapabilities = [ "" ];
    SystemCallErrorNumber = "EPERM";
  };
  lantian.harden."prometheus-exportarr-sonarr-exporter".enable = true;
}
