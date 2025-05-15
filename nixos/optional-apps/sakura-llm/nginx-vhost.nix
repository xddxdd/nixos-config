{
  LT,
  config,
  ...
}:
{
  lantian.nginxVhosts = {
    "sakura-llm.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.SakuraLLM}";
        proxyNoTimeout = true;
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "sakura-llm.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.SakuraLLM}";
        proxyNoTimeout = true;
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
