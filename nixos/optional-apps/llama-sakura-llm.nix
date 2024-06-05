{
  pkgs,
  LT,
  config,
  utils,
  ...
}:
let
  # https://github.com/SakuraLLM/Sakura-13B-Galgame
  model = pkgs.linkFarm "llama-model" {
    "sakura-14b-qwen2beta-v0.9-iq4_xs_ver2.gguf" = pkgs.fetchurl {
      name = "sakura-14b-qwen2beta-v0.9-iq4_xs_ver2.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-Qwen2beta-v0.9-GGUF/resolve/main/sakura-14b-qwen2beta-v0.9-iq4_xs_ver2.gguf?download=true";
      sha256 = "0g6jmm10jmc3hr6zqh00flg988ij4hspgac1ppmanas7mbmbj0nr";
    };
    "sakura-14b-qwen2beta-v0.9.1-iq4xs.gguf" = pkgs.fetchurl {
      name = "sakura-14b-qwen2beta-v0.9.1-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-Qwen2beta-v0.9.1-GGUF/resolve/main/sakura-14b-qwen2beta-v0.9.1-iq4xs.gguf?download=true";
      sha256 = "0wykq0lxms47xnj0nv5r7x79bfg0gm26z97ngi9h3b32a8dwqx9l";
    };
    "sakura-14b-qwen2beta-v0.9.1-q4km.gguf" = pkgs.fetchurl {
      name = "sakura-14b-qwen2beta-v0.9.1-q4km.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-Qwen2beta-v0.9.1-GGUF/resolve/main/sakura-14b-qwen2beta-v0.9.1-q4km.gguf?download=true";
      sha256 = "0psrg53ms90ccwiq136yg9s8mn5xg0z2lv40xhwbpcfr5ca8l6sk";
    };
    "sakura-14b-qwen2beta-v0.9.2-iq4xs.gguf" = pkgs.fetchurl {
      name = "sakura-14b-qwen2beta-v0.9.2-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-Qwen2beta-v0.9.2-GGUF/resolve/main/sakura-14b-qwen2beta-v0.9.2-iq4xs.gguf?download=true";
      sha256 = "0rzd7jd0ifl9c4qx9cns2nb7h2ha5fxmaphlf6ixm9g2wnbpwji5";
    };
    "sakura-14b-qwen2beta-v0.9.2-q4km.gguf" = pkgs.fetchurl {
      name = "sakura-14b-qwen2beta-v0.9.2-q4km.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-Qwen2beta-v0.9.2-GGUF/resolve/main/sakura-14b-qwen2beta-v0.9.2-q4km.gguf?download=true";
      sha256 = "198180v585ay0bi7v0v0sm3ih1qsp2ay8flg79ygl9vkbgiimblb";
    };
    "sakura-32b-qwen2beta-v0.9-iq4xs.gguf" = pkgs.fetchurl {
      name = "sakura-32b-qwen2beta-v0.9-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.9-GGUF/resolve/main/sakura-32b-qwen2beta-v0.9-iq4xs.gguf?download=true";
      sha256 = "0zr7b9fqlflgw40lzxfrd3sal08y3x86ghy4d9zby0m2zbcbd01s";
    };
    "sakura-32b-qwen2beta-v0.9-q4km.gguf" = pkgs.fetchurl {
      name = "sakura-32b-qwen2beta-v0.9-q4km.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.9-GGUF/resolve/main/sakura-32b-qwen2beta-v0.9-q4km.gguf?download=true";
      sha256 = "15p63khy3b7z15kk97a794d6agjzkalkalvizajlmz9jfh7fh03k";
    };
    "sakura-32b-qwen2beta-v0.9.1-iq4xs.gguf" = pkgs.fetchurl {
      name = "sakura-32b-qwen2beta-v0.9.1-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.9.1-GGUF/resolve/main/sakura-32b-qwen2beta-v0.9.1-iq4xs.gguf?download=true";
      sha256 = "1i1qkc8yy9ijp4hfhnvzwbkkii52f190l82wadxry1l11whppb35";
    };
    "sakura-32b-qwen2beta-v0.10pre1-iq4xs.gguf" = pkgs.fetchurl {
      name = "sakura-32b-qwen2beta-v0.10pre1-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-32B-Qwen2beta-v0.10pre1-GGUF/resolve/main/sakura-32b-qwen2beta-v0.10pre1-iq4xs.gguf?download=true";
      sha256 = "0r7v5bdlf8qm0zv0yqi8w641zh8yvpbhyqm765hm28f55ycsw14i";
    };
  };

  cfg = config.services.llama-cpp;
  modelName = "sakura-32b-qwen2beta-v0.9.1-iq4xs.gguf";
in
{
  services.llama-cpp = {
    # Do not enable, I define systemd service myselv
    enable = false;

    package = pkgs.lantianCustomized.llama-cpp;
    host = "127.0.0.1";
    port = LT.port.LlamaCpp;
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
        "-fa"
      ];
  };

  systemd.services.llama-cpp = {
    description = "LLaMA C++ server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      Type = "idle";
      KillSignal = "SIGINT";
      ExecStart = "${cfg.package}/bin/llama-server --log-disable --host ${cfg.host} --port ${builtins.toString cfg.port} -m ${modelName} ${utils.escapeSystemdExecArgs cfg.extraFlags}";
      Restart = "on-failure";
      RestartSec = 300;
      WorkingDirectory = "${model}";

      User = "llama-cpp";
      Group = "llama-cpp";

      # for GPU acceleration
      PrivateDevices = false;
    };

    unitConfig.ConditionPathExists = "/dev/nvidia0";
  };

  users.users.llama-cpp = {
    group = "llama-cpp";
    isSystemUser = true;
  };
  users.groups.llama-cpp = { };

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
