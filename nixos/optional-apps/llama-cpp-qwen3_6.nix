{
  pkgs,
  config,
  LT,
  ...
}:
{
  imports = [ ./llama-cpp.nix ];

  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override { cudaSupport = true; };
    host = "127.0.0.1";
    port = LT.port.LlamaCpp.Qwen3_6;
    settings.hf-repo = "unsloth/Qwen3.6-35B-A3B-GGUF:UD-IQ4_XS";
  };

  lantian.nginxVhosts = {
    "llama-cpp.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp.Qwen3_6}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "llama-cpp.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp.Qwen3_6}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
