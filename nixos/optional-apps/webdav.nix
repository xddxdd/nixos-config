{
  config,
  ...
}:
{
  services.webdav = {
    enable = true;
    user = "lantian";
    group = "lantian";
    settings = {
      address = "unix:/run/webdav/webdav.sock";
      directory = "/mnt/storage";
      behindProxy = true;
      permissions = "CRUD";
      noPassword = true;
      users = [
        {
          username = "lantian";
        }
      ];
    };
  };

  systemd.services.webdav = {
    postStart = ''
      while [ ! -S /run/webdav/webdav.sock ]; do sleep 1; done
      chmod 777 /run/webdav/webdav.sock
    '';
    serviceConfig = {
      RuntimeDirectory = "webdav";
    };
  };

  lantian.nginxVhosts."dav.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/webdav/webdav.sock";
        proxyNoTimeout = true;
        enableBasicAuth = true;
      };
    };

    sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
