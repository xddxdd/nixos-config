{
  LT,
  config,
  pkgs,
  lib,
  ...
}:
{
  services.bazarr = {
    enable = true;
    user = "lantian";
    group = "users";
    settings.general.port = LT.port.Bazarr;
  };
  systemd.services.bazarr = {
    serviceConfig = LT.serviceHarden // {
      RestartSec = "5s";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      StateDirectory = "bazarr";
      MemoryDenyWriteExecute = false;
      BindPaths = [ "/var/lib/bazarr" ];
      BindReadOnlyPaths = [ "/etc/resolv.conf" ];
    };
    confinement = {
      enable = true;
      fullUnit = true;
    };
  };

  lantian.localVhosts.bazarr = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Bazarr}";
      };
    };
  };

  services.prometheus.exporters.exportarr-bazarr = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.BazarrExporter;
    # sonarr.localhost /etc/hosts entries are gone; use the loopback direct
    url = "http://127.0.0.1:${LT.portStr.Bazarr}";
    environment = {
      INTERFACE = LT.this.ltnet.IPv4;
      PORT = LT.portStr.Prometheus.BazarrExporter;
      LOG_LEVEL = "warn";
    };
    inherit (config.services.bazarr) user group;
  };
  systemd.services.prometheus-exportarr-bazarr-exporter = {
    preStart = ''
      ${lib.getExe pkgs.yq-go} -r ".auth.apikey" /var/lib/bazarr/config/config.yaml > /run/prometheus-exportarr-bazarr-exporter/apikey
    '';
    environment.API_KEY_FILE = lib.mkForce "/run/prometheus-exportarr-bazarr-exporter/apikey";
    serviceConfig = {
      RuntimeDirectory = "prometheus-exportarr-bazarr-exporter";
      RuntimeDirectoryMode = "0700";
      DynamicUser = lib.mkForce false;
      RestartSec = "5s";
      # chroot's tmpfs root is ephemeral; bind data dir through
      BindReadOnlyPaths = [ "/var/lib/bazarr" ];

      AmbientCapabilities = [ "" ];
      PrivateMounts = true;
      SystemCallErrorNumber = "EPERM";
    };
    confinement = {
      enable = true;
      fullUnit = true;
    };
  };
}
