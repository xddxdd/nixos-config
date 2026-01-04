{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  llama-cpp = pkgs.llama-cpp.override { cudaSupport = true; };
  model = pkgs.linkFarm "llama-model" {
    "Qwen3-Reranker-8B.gguf" = pkgs.fetchurl {
      url = "https://huggingface.co/QuantFactory/Qwen3-Reranker-8B-GGUF/resolve/main/Qwen3-Reranker-8B.Q4_K_M.gguf";
      hash = "sha256-Xt6adEs3R53C9adCCG7WVko0GFpcdilZIyuBn4XjWqg=";
    };
  };
in
{
  systemd.services.llama-cpp-qwen3-reranker = {
    description = "LLaMA C++ server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ curl ];
    postStart = ''
      curl -fsSL \
        --retry 120 \
        --retry-delay 5 \
        --retry-max-time 300 \
        --retry-all-errors \
        http://127.0.0.1:${LT.portStr.LlamaCpp.Qwen3Reranker}/health
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "idle";
      KillSignal = "SIGINT";
      ExecStart = "${lib.getExe' llama-cpp "llama-server"} --host 127.0.0.1 --port ${LT.portStr.LlamaCpp.Qwen3Reranker} -m 'Qwen3-Reranker-8B.gguf' --ctx-size 32768 --rerank";
      Restart = "on-failure";
      RestartSec = 300;
      TimeoutStartSec = 600;
      WorkingDirectory = "${model}";

      User = "llama-cpp";
      Group = "llama-cpp";

      # for GPU acceleration
      PrivateDevices = false;
    };
  };

  users.users.llama-cpp = {
    group = "llama-cpp";
    isSystemUser = true;
  };
  users.groups.llama-cpp = { };

  lantian.nginxVhosts = {
    "qwen3-reranker.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp.Qwen3Reranker}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "qwen3-reranker.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaCpp.Qwen3Reranker}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
