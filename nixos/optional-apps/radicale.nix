{ LT, ... }:
{
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "127.0.0.1:${LT.portStr.Radicale}" ];
      auth.type = "http_x_remote_user";
      storage.filesystem_folder = "/var/lib/radicale/collections";
    };
  };

  systemd.services.radicale.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };

  lantian.nginxVhosts."cal.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Radicale}";
        enableBasicAuth = true;
      };
    };

    sslCertificate = "xuyh0120.win_ecc";
    blockDotfiles = false;
    noIndex.enable = true;
  };
}
