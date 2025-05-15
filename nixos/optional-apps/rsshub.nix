{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.rsshub = {
    extraOptions = [ "--pull=always" ];
    image = "diygod/rsshub:chromium-bundled";
    environment = {
      TZ = config.time.timeZone;
      CACHE_CONTENT_EXPIRE = "600";
    };
    ports = [ "127.0.0.1:${LT.portStr.RSSHub}:1200" ];
  };

  lantian.nginxVhosts."rsshub.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.RSSHub}";
      };
    };

    sslCertificate = "xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
