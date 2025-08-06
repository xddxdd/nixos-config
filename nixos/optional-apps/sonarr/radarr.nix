{ LT, config, ... }:
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

  lantian.nginxVhosts = {
    "radarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Radarr}";
        };
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "radarr.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Radarr}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
