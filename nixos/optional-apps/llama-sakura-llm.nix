{
  pkgs,
  LT,
  config,
  ...
}:
let
  # https://github.com/SakuraLLM/Sakura-13B-Galgame
  model = {
    "sakura-32b-qwen2beta-v0.9-iq4xs" = pkgs.fetchurl {
      name = "sakura-32b-qwen2beta-v0.9-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.9-GGUF/resolve/main/sakura-32b-qwen2beta-v0.9-iq4xs.gguf?download=true";
      sha256 = "0zr7b9fqlflgw40lzxfrd3sal08y3x86ghy4d9zby0m2zbcbd01s";
    };
    "sakura-32b-qwen2beta-v0.9-q4km" = pkgs.fetchurl {
      name = "sakura-32b-qwen2beta-v0.9-q4km.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.9-GGUF/resolve/main/sakura-32b-qwen2beta-v0.9-q4km.gguf?download=true";
      sha256 = "15p63khy3b7z15kk97a794d6agjzkalkalvizajlmz9jfh7fh03k";
    };
    "sakura-32b-qwen2beta-v0.9.1-iq4xs" = pkgs.fetchurl {
      name = "sakura-32b-qwen2beta-v0.9.1-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.9.1-GGUF/resolve/main/sakura-32b-qwen2beta-v0.9.1-iq4xs.gguf?download=true";
      sha256 = "1i1qkc8yy9ijp4hfhnvzwbkkii52f190l82wadxry1l11whppb35";
    };
    "sakura-32b-qwen2beta-v0.10pre1-iq4xs" = pkgs.fetchurl {
      name = "sakura-32b-qwen2beta-v0.10pre1-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.10pre1-GGUF/resolve/main/sakura-32b-qwen2beta-v0.10pre1-iq4xs.gguf?download=true";
      sha256 = "0r7v5bdlf8qm0zv0yqi8w641zh8yvpbhyqm765hm28f55ycsw14i";
    };
  };
in
{
  services.llama-cpp = {
    enable = true;
    package = pkgs.lantianCustomized.llama-cpp;
    host = "127.0.0.1";
    port = LT.port.LlamaCpp;
    model = model."sakura-32b-qwen2beta-v0.9-iq4xs";
    extraFlags =
      let
        concurrency = 4;
      in
      [
        "-c"
        "${builtins.toString (concurrency * 2048)}"
        "-ngl"
        "100"
        "-np"
        "${builtins.toString concurrency}"
        "-cb"
      ];
  };

  lantian.nginxVhosts = {
    "llama-cpp.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp}";
        proxyNoTimeout = true;
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "llama-cpp.localhost" = {
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
