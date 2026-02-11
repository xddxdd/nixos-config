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
    listenPort = LT.port.Bazarr;
    user = "lantian";
    group = "users";
  };
  systemd.services.bazarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      StateDirectory = "bazarr";
      MemoryDenyWriteExecute = false;
    };
  };

  lantian.nginxVhosts = {
    "bazarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Bazarr}";
        };
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
    };
    "bazarr.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Bazarr}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };

  services.prometheus.exporters.exportarr-bazarr = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.BazarrExporter;
    url = "http://bazarr.localhost";
    environment = {
      INTERFACE = LT.this.ltnet.IPv4;
      PORT = LT.portStr.Prometheus.BazarrExporter;
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
    };
  };
}
