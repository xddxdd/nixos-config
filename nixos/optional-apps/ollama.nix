{
  LT,
  config,
  ...
}:
{
  services.ollama = {
    enable = true;
    port = LT.port.Ollama;
    acceleration = "cuda";
    environmentVariables = {
      OLLAMA_ORIGINS = "*";
    };
  };

  lantian.nginxVhosts = {
    "ollama.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Ollama}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "ollama.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Ollama}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}