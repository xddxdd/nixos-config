{ LT, ... }:
{
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "127.0.0.1:${LT.portStr.Radicale}" ];
      auth.type = "http_x_remote_user";
      storage.filesystem_folder = "/var/lib/radicale/collections";
      sharing = {
        type = "csv";
        collection_by_token = true;
        permit_create_token = true;
      };
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
      # Share-by-token URLs are capability URLs Radicale serves without
      # authentication, so they must not inherit basic auth or X-Remote-User.
      "/.token/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Radicale}";
      };
    };

    accessibleBy = "private";
    sslCertificate = "lets-encrypt-xuyh0120.win";
    blockDotfiles = false;
    noIndex.enable = true;
  };
}
