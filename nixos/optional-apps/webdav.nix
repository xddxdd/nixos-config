{
  LT,
  config,
  ...
}:
{
  services.webdav = {
    enable = true;
    user = "lantian";
    group = "lantian";
    settings = {
      address = "127.0.0.1";
      port = LT.port.WebDAV;
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

  lantian.nginxVhosts."dav.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.WebDAV}";
        proxyNoTimeout = true;
        enableBasicAuth = true;
      };
    };

    sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
