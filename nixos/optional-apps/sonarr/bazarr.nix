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
    url = "http://bazarr.localhost";
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
    };
  };
}
