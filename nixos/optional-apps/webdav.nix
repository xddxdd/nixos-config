{
  config,
  LT,
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
    unitConfig.RequiresMountsFor = [ (LT.escapeMountPath config.services.webdav.settings.directory) ];
    postStart = ''
      while [ ! -S /run/webdav/webdav.sock ]; do sleep 1; done
      chmod 777 /run/webdav/webdav.sock
    '';
    serviceConfig = LT.serviceHarden // {
      RestartSec = "5s";
      RuntimeDirectory = "webdav";
      # chroot's tmpfs root is ephemeral; bind served directory through
      BindPaths = [ "/mnt/storage" "/run/webdav" ];
    };
    confinement = {
      enable = true;
      fullUnit = true;
    };
  };

  lantian.localVhosts.dav = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/webdav/webdav.sock";
        proxyNoTimeout = true;
        enableBasicAuth = true;
      };
    };
  };
}
