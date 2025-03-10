{
  LT,
  inputs,
  config,
  pkgs,
  ...
}:
{
  age.secrets.huggingface-token-env.file = inputs.secrets + "/huggingface-token-env.age";

  virtualisation.oci-containers.containers.sglang-sakura-llm = {
    extraOptions = [
      # Pulling on startup causes network issues if freshly booted
      # "--pull=always"
      "--net=host"
      "--ipc=host"
      "--gpus=all"
    ];
    image = "lmsysorg/sglang";
    environment = {
      TORCHINDUCTOR_CACHE_DIR = "/var/cache/torchinductor";
    };
    environmentFiles = [
      config.age.secrets.huggingface-token-env.path
    ];
    volumes = [
      "/var/cache/huggingface:/root/.cache/huggingface"
      "/var/cache/torchinductor:/var/cache/torchinductor"
    ];
    cmd = [
      "python3"
      "-m"
      "sglang.launch_server"
      "--model-path"
      "reinforce20001/SakuraLLM.Sakura-14B-Qwen2.5-v1.0-W8A8-Int8-V2"
      "--host"
      "127.0.0.1"
      "--port"
      LT.portStr.SakuraLLM
      "--disable-overlap"
      "--context-length"
      "2048"
      "--enable-metrics"
      "--enable-torch-compile"
      "--torch-compile-max-bs"
      "1"
      "--mem-fraction-static"
      "0.8"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/cache/huggingface 755 root root"
    "d /var/cache/torchinductor 755 root root"
  ];

  systemd.services.podman-sglang-sakura-llm = {
    path = with pkgs; [ curl ];
    postStart = ''
      curl \
        --fail \
        --retry 100 \
        --retry-delay 5 \
        --retry-max-time 300 \
        --retry-all-errors \
        http://127.0.0.1:${LT.portStr.SakuraLLM}/health
    '';
  };
}
