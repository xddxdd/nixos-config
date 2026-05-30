{
  LT,
  ...
}:
{
  services.rsshub = {
    enable = true;
    settings = {
      PORT = LT.port.RSSHub;
      CACHE_CONTENT_EXPIRE = "600";
    };
    redis.createLocally = true;
  };

  lantian.nginxVhosts."rsshub.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.RSSHub}";
      };
    };

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
