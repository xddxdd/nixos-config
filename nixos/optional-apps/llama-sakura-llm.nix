{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  modelName = "sakura-13b-lnovel-v0.9b-Q8_0.gguf";
  model = pkgs.linkFarm "llama-model" {
    "${modelName}" = pkgs.fetchurl {
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-LNovel-v0.9b-GGUF/resolve/main/sakura-13b-lnovel-v0.9b-Q8_0.gguf?download=true";
      sha256 = "1vjp51ca78b9ri23kgaj42d0yibvdg3hy9c2cg0ki7yb31x0nza2";
    };
  };
in
{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override { cudaSupport = true; };
    host = "127.0.0.1";
    port = LT.port.LlamaCpp;
    model = "${model}/${modelName}";
    extraFlags = [
      "-c"
      "2048"
      "-ngl"
      "100"
    ];
  };

  lantian.nginxVhosts = {
    "llama-cpp.${config.networking.hostName}.xuyh0120.win" = {
      locations."/".proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp}";

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "llama-cpp.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/".proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp}";

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
