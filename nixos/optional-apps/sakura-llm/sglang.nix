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
      # Causes "Counters can only be incremented by non-negative amounts" error
      # Wait until https://github.com/sgl-project/sglang/pull/4660 is published in next release
      # "--enable-metrics"
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

  systemd.services.sglang-sakura-llm-watchdog = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-sglang-sakura-llm.service" ];
    requires = [ "podman-sglang-sakura-llm.service" ];

    path = with pkgs; [
      curl
      systemd
    ];

    script = ''
      if ! curl \
        --fail \
        --max-time 60 \
        --retry 3 \
        --retry-delay 1 \
        --retry-max-time 60 \
        --retry-all-errors \
        -XPOST \
        --data '{"model":"","messages":[{"role":"system","content":"你是一个轻小说翻译模型，可以流畅通顺地以日本轻小说的风格将日文翻译成简体中文，并联系上下文正确使用人称代词，不擅自添加原文中没有的代词。"},{"role":"user","content":"将下面的日文文本翻译成中文：国境の長いトンネルを抜けると雪国であった。夜の底が白くなった。信号所に汽車が止まった。"}],"temperature":0.1,"top_p":0.3,"max_tokens":74,"frequency_penalty":0.2}' \
        http://127.0.0.1:${LT.portStr.SakuraLLM}/v1/chat/completions
      then
        systemctl restart podman-sglang-sakura-llm.service
      fi
    '';
  };

  systemd.timers.sglang-sakura-llm-watchdog = {
    wantedBy = [ "timers.target" ];
    after = [ "podman-sglang-sakura-llm.service" ];
    requires = [ "podman-sglang-sakura-llm.service" ];
    partOf = [ "sglang-sakura-llm-watchdog.service" ];
    timerConfig = {
      OnCalendar = "minutely";
      Persistent = true;
      Unit = "sglang-sakura-llm-watchdog.service";
    };
  };
}
