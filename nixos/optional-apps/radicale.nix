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
    # chroot's tmpfs root is ephemeral; bind host data dir through
    BindPaths = [ "/var/lib/radicale/collections" ];
  };

  lantian.harden.radicale = {
    enable = true;
  };

  lantian.nginxVhosts."cal.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Radicale}";
        enableBasicAuth = true;
      };
    };

    accessibleBy = "private";
    sslCertificate = "lets-encrypt-xuyh0120.win";
    blockDotfiles = false;
    noIndex.enable = true;
  };
}
