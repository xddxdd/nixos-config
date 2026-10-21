{
  lib,
  config,
  LT,
  ...
}:
{
  services.prowlarr = {
    enable = true;
    settings.server.allowedHosts = lib.concatStringsSep "," (
      [
        "localhost"
        "127.0.0.1"
        "[::1]"
        "prowlarr.localhost"
        "prowlarr.${config.networking.hostName}.xuyh0120.win"
        LT.this.ltnet.IPv4
      ]
      ++ config.lantian.localVhosts.prowlarr.serverAliases
    );
  };
  systemd.services.prowlarr = {
    serviceConfig = LT.serviceHarden // {
      StateDirectory = "prowlarr";
      BindPaths = [ "/var/lib/prowlarr" ];
      BindReadOnlyPaths = [
        "/etc/passwd"
        "/etc/group"
        "/etc/resolv.conf"
        "${config.environment.etc.hosts.source}:/etc/hosts"
        "${
          config.environment.etc."ssl/certs/ca-certificates.crt".source
        }:/etc/ssl/certs/ca-certificates.crt"
        "${config.environment.etc."ssl/certs/ca-certificates.crt".source}:/etc/ssl/certs/ca-bundle.crt"
      ];
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      MemoryDenyWriteExecute = false;
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "lantian";
      Group = lib.mkForce "users";
      RestartSec = "5s";
    };
    confinement = {
      enable = true;
      fullUnit = true;
    };
  };
  lantian.localVhosts.prowlarr = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Prowlarr}";
      };
    };
  };

  services.prometheus.exporters.exportarr-prowlarr = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.ProwlarrExporter;
    # sonarr.localhost /etc/hosts entries are gone; use the loopback direct
    url = "http://127.0.0.1:${LT.portStr.Prowlarr}";
    environment = {
      INTERFACE = LT.this.ltnet.IPv4;
      PORT = LT.portStr.Prometheus.ProwlarrExporter;
      CONFIG = "/var/lib/prowlarr/config.xml";
      LOG_LEVEL = "warn";
    };
    user = "lantian";
    group = "users";
  };
  systemd.services.prometheus-exportarr-prowlarr-exporter.serviceConfig = {
    DynamicUser = lib.mkForce false;
    RestartSec = "5s";
    # chroot's tmpfs root is ephemeral; bind data dir through
    BindReadOnlyPaths = [ "/var/lib/prowlarr" ];

    AmbientCapabilities = [ "" ];
    SystemCallErrorNumber = "EPERM";
  };
  lantian.harden."prometheus-exportarr-prowlarr-exporter" = true;
}
