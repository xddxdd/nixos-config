{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.iyuuplus = {
    image = "docker.io/iyuucn/iyuuplus-dev:latest";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    ports = [ "127.0.0.1:${LT.portStr.IyuuPlus}:8780" ];
    volumes = [
      "/var/lib/iyuu/iyuu:/iyuu"
      "/var/lib/iyuu/data:/data"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/iyuu/iyuu 755 root root"
    "d /var/lib/iyuu/data 755 root root"
  ];

  lantian.nginxVhosts = {
    "iyuu.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.IyuuPlus}";
          proxyWebsockets = true;
        };
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "iyuu.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.IyuuPlus}";
          proxyWebsockets = true;
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
