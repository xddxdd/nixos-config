{
  pkgs,
  lib,
  LT,
  config,
  utils,
  ...
}:
let
  # https://github.com/SakuraLLM/Sakura-13B-Galgame
  model = pkgs.linkFarm "llama-model" {
    "sakura-14b-qwen2.5-v1.0-iq4xs.gguf" = pkgs.fetchurl {
      name = "sakura-14b-qwen2.5-v1.0-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-Qwen2.5-v1.0-GGUF/resolve/main/sakura-14b-qwen2.5-v1.0-iq4xs.gguf?download=true";
      sha256 = "0jp90qg1pnvwx2slnz4y1h2156kwfvgfwg2xcv81hd0ikkwqibrl";
    };
    "sakura-14b-qwen2.5-v1.0-q6k.gguf" = pkgs.fetchurl {
      name = "sakura-14b-qwen2.5-v1.0-q6k.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-Qwen2.5-v1.0-GGUF/resolve/main/sakura-14b-qwen2.5-v1.0-q6k.gguf?download=true";
      sha256 = "0xsb33ydjn01vxlm67v78f8jz74pbc8j4f24y4nc8p618cmc47rc";
    };
  };

  cfg = config.services.llama-cpp;
  inherit (config.lantian.sakura-llm) modelName;
in
{
  options.lantian.sakura-llm = {
    enable = (lib.mkEnableOption "Llama API with Sakura LLM") // {
      default = true;
    };
    modelName = lib.mkOption {
      type = lib.types.str;
      default = "sakura-14b-qwen2.5-v1.0-iq4xs.gguf";
    };
  };

  config = lib.mkIf config.lantian.sakura-llm.enable {
    services.llama-cpp = {
      # Do not enable, I define systemd service myself
      enable = false;

      package = pkgs.llama-cpp.override { cudaSupport = true; };
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
          "--metrics"
          "-sm"
          "none"
        ];
    };

    systemd.services.llama-cpp = {
      description = "LLaMA C++ server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ curl ];
      postStart = ''
        curl \
          --fail \
          --retry 30 \
          --retry-delay 5 \
          --retry-max-time 120 \
          --retry-all-errors \
          http://${cfg.host}:${builtins.toString cfg.port}/health
      '';

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
  };
}
