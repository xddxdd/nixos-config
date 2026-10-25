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
    settings.server.allowedHosts = lib.concatStringsSep "," (
      [
        "localhost"
        "127.0.0.1"
        "[::1]"
        "radarr.localhost"
        "radarr.${config.networking.hostName}.xuyh0120.win"
        LT.this.ltnet.IPv4
      ]
      ++ config.lantian.localVhosts.radarr.serverAliases
    );
  };
  systemd.services.radarr = {
    serviceConfig = {
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
  };
  lantian.harden.radarr = {
    enable = true;
    passwd = true;
    etc = {
      "resolv.conf" = true;
      # The configured local download client uses localhost.
      "ssl/certs/ca-certificates.crt" = true;
      "ssl/certs/ca-bundle.crt" = config.environment.etc."ssl/certs/ca-certificates.crt".source;
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
  lantian.harden."prometheus-exportarr-radarr-exporter".enable = true;
}
