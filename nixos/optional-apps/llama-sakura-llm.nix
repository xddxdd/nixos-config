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
    "sakura-1b8-qwen2beta-v0.9.1-fp16.gguf" = pkgs.fetchurl {
      name = "sakura-1b8-qwen2beta-v0.9.1-fp16.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-1B8-Qwen2beta-v0.9.1-GGUF/resolve/main/sakura-1b8-qwen2beta-v0.9.1-fp16.gguf?download=true";
      sha256 = "15pjh8qm0hq7ah6gx600km71hzr2wg85b6yg1mrbsddjdamvh25x";
    };
    "sakura-14b-qwen2beta-v0.9.2-iq4xs.gguf" = pkgs.fetchurl {
      name = "sakura-14b-qwen2beta-v0.9.2-iq4xs.gguf";
      url = "https://huggingface.co/SakuraLLM/Sakura-14B-Qwen2beta-v0.9.2-GGUF/resolve/main/sakura-14b-qwen2beta-v0.9.2-iq4xs.gguf?download=true";
      sha256 = "0rzd7jd0ifl9c4qx9cns2nb7h2ha5fxmaphlf6ixm9g2wnbpwji5";
    };
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
  inherit (config.lantian.llama-sakura-llm) modelName;
in
{
  options.lantian.llama-sakura-llm = {
    enable = (lib.mkEnableOption "Llama API with Sakura LLM") // {
      default = true;
    };
    modelName = lib.mkOption {
      type = lib.types.str;
      default = "sakura-14b-qwen2.5-v1.0-q6k.gguf";
    };
  };

  config = lib.mkIf config.lantian.llama-sakura-llm.enable {
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
        ];
    };

    systemd.services.llama-cpp = {
      description = "LLaMA C++ server";
      after = [ "network.target" ];

      path = with pkgs; [ curl ];
      postStart = ''
        while ! curl -f http://${cfg.host}:${builtins.toString cfg.port}/health; do
          echo "Still waiting for llama-cpp to start"
          sleep 1
        done
      '';

      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        KillSignal = "SIGINT";
        ExecStart = "${cfg.package}/bin/llama-server --log-disable --host ${cfg.host} --port ${builtins.toString cfg.port} -m ${modelName} ${utils.escapeSystemdExecArgs cfg.extraFlags}";
        WorkingDirectory = "${model}";

        User = "llama-cpp";
        Group = "llama-cpp";

        # for GPU acceleration
        PrivateDevices = false;
      };

      unitConfig = {
        ConditionPathExists = "/dev/nvidia0";
        StopWhenUnneeded = true;
      };
    };

    systemd.services.llama-cpp-proxy = {
      requires = [
        "llama-cpp.service"
        "llama-cpp-proxy.socket"
      ];
      after = [
        "llama-cpp.service"
        "llama-cpp-proxy.socket"
      ];
      script = ''
        exec ${pkgs.systemd}/lib/systemd/systemd-socket-proxyd \
          --exit-idle-time=120s \
          ${cfg.host}:${builtins.toString cfg.port}
      '';
    };

    systemd.sockets.llama-cpp-proxy = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "/run/llama-cpp.sock" ];
      socketConfig = {
        SocketUser = "llama-cpp";
        SocketGroup = "llama-cpp";
      };
    };

    users.users.llama-cpp = {
      group = "llama-cpp";
      isSystemUser = true;
    };
    users.groups.llama-cpp.members = [ "nginx" ];

    lantian.nginxVhosts = {
      "llama-cpp.${config.networking.hostName}.xuyh0120.win" = {
        locations."/" = {
          proxyPass = "http://unix:/run/llama-cpp.sock";
          proxyNoTimeout = true;
        };

        sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
        noIndex.enable = true;
      };
      "llama-cpp.localhost" = {
        listenHTTP.enable = true;
        listenHTTPS.enable = false;

        locations."/" = {
          proxyPass = "http://unix:/run/llama-cpp.sock";
          proxyNoTimeout = true;
        };

        noIndex.enable = true;
        accessibleBy = "localhost";
      };
    };
  };
}
