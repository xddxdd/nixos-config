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
    user = "ollama";
    group = "ollama";
    environmentVariables = {
      OLLAMA_ORIGINS = "*";
      OLLAMA_KEEP_ALIVE = "900";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_SCHED_SPREAD = "1";
    };
  };

  systemd.services.ollama.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };

  lantian.nginxVhosts = {
    "ollama.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Ollama}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
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
