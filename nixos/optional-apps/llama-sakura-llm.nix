{
  pkgs,
  LT,
  config,
  ...
}:
let
  # https://github.com/SakuraLLM/Sakura-13B-Galgame
  model = pkgs.linkFarm "llama-model" {
    "sakura-32b-qwen2beta-v0.9-iq4xs.gguf" = pkgs.fetchurl {
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.9-GGUF/resolve/main/sakura-32b-qwen2beta-v0.9-iq4xs.gguf?download=true";
      sha256 = "0skil1kn4ys8hh5vr87k2mrlmdizsklkfz3jwzrdy8q6xh6gc4s6";
    };
    "sakura-32b-qwen2beta-v0.10pre1-iq4xs.gguf" = pkgs.fetchurl {
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.10pre1-GGUF/resolve/main/sakura-32b-qwen2beta-v0.10pre1-iq4xs.gguf?download=true";
      sha256 = "1rda8hi2i796qaf8pfyrddlzw6l355rm41cvjrwn901f4jgh2844";
    };
  };
in
{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override { cudaSupport = true; };
    host = "127.0.0.1";
    port = LT.port.LlamaCpp;
    model = "${model}/sakura-32b-qwen2beta-v0.9-iq4xs.gguf";
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
