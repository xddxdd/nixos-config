{
  LT,
  config,
  ...
}:
{
  lantian.nginxVhosts = {
    "sakura-llm.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp}";
        proxyNoTimeout = true;
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "sakura-llm.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp}";
        proxyNoTimeout = true;
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
