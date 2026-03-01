{
  LT,
  config,
  pkgs,
  lib,
  ...
}:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda.override {
      cudaArches = [ "sm_61" ] ++ pkgs.cudaPackages.flags.realArches;
    };
    port = LT.port.Ollama;
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
    DynamicUser = lib.mkForce false;
  };

  lantian.nginxVhosts = {
    "ollama.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Ollama}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
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

  users.users.ollama = {
    group = "ollama";
    isSystemUser = true;
  };
  users.groups.ollama = { };
}
