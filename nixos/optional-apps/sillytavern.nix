{ LT, config, ... }:
{
  services.sillytavern = {
    enable = true;
    port = LT.port.SillyTavern;
    listenAddressIPv4 = "127.0.0.1";
    listenAddressIPv6 = "::1";
    whitelist = false;
  };

  lantian.nginxVhosts."tavern.${config.networking.hostName}.xuyh0120.win" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.SillyTavern}";
      proxyWebsockets = true;
      proxyNoTimeout = true;
    };

    sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
