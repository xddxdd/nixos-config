{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.qinglong = {
    extraOptions = [ "--pull=always" ];
    environment = {
      QlBaseUrl = "/";
      QlPort = LT.portStr.Qinglong;
    };
    image = "ghcr.io/whyour/qinglong";
    ports = [ "127.0.0.1:${LT.portStr.Qinglong}:${LT.portStr.Qinglong}" ];
    volumes = [ "/var/lib/qinglong:/ql/data" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/qinglong 755 root root"
  ];

  lantian.nginxVhosts = {
    "qinglong.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Qinglong}";
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "qinglong.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Qinglong}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
