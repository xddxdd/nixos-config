_: {
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

  lantian.localVhosts.dav = {
    accessibleBy = "public";
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/webdav/webdav.sock";
        proxyNoTimeout = true;
        enableBasicAuth = true;
      };
    };
  };
}
