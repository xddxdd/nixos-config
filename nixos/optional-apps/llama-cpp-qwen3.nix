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
    settings = {
      host = "127.0.0.1";
      port = LT.port.LlamaCpp.Qwen3;
      hf-repo = "unsloth/Qwen3.8-27B-GGUF:UD-IQ4_XS";
      cache-type-k = "q4_0";
      cache-type-v = "q4_0";
      mmproj-url = "https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/main/mmproj-F16.gguf";
      spec-type = "draft-mtp";
      spec-draft-n-max = 2;
      ctx-size = 128000;
      batch-size = 1024;
      ubatch-size = 512;
      image-min-tokens = 1024;
    };
  };

  lantian.nginxVhosts = {
    "llama-cpp.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp.Qwen3}";
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
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp.Qwen3}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
