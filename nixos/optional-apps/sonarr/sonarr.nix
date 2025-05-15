{ LT, config, ... }:
{
  services.sonarr = {
    enable = true;
    user = "lantian";
    group = "users";
    dataDir = "/var/lib/sonarr";
  };
  systemd.services.sonarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      StateDirectory = "sonarr";
      MemoryDenyWriteExecute = false;
    };
  };

  lantian.nginxVhosts = {
    "sonarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Sonarr}";
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "sonarr.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Sonarr}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
