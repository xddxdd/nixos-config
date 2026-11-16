{
  config,
  lib,
  pkgs,
  LT,
  ...
}:
let
  llama-server = lib.getExe' (pkgs.llama-cpp.override { cudaSupport = true; }) "llama-server";
  podman = lib.getExe pkgs.podman;
  sglang-image = "docker.io/lmsysorg/sglang:v0.5.6.post2-cu130-amd64-runtime";

  modelType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Display name.";
      };
      kind = lib.mkOption {
        type = lib.types.enum [
          "llama"
          "maya"
          "sglang"
          "strata"
        ];
        default = "llama";
        description = "Server that runs the model.";
      };
      mode = lib.mkOption {
        type = lib.types.enum [
          "chat"
          "embeddings"
          "rerank"
        ];
        default = "chat";
        description = "Endpoint the model serves.";
      };
      ctxSize = lib.mkOption {
        type = lib.types.int;
        description = "Context size.";
      };
      maxTokens = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Largest reply clients ask for, for clients that need it declared.";
      };
      thinking = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "The model emits reasoning content.";
      };
      vision = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "The model accepts images.";
      };
      minVramGB = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = "Smallest VRAM the model runs in.";
      };
      _cmd = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        readOnly = true;
        description = ''
          Command that runs the model, rendered here from the fields above.
          Null on hosts without the VRAM the model needs.
        '';
      };
      _provision = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        readOnly = true;
        description = ''
          Command that downloads and prepares the model's data, run once per
          host before the model is served. Null for servers that fetch their
          own weights when they start (llama, sglang).
        '';
      };
      _provisionGuard = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        readOnly = true;
        description = ''
          Path (glob) whose existence means the model is already provisioned,
          as a systemd condition, so provisioning runs only when it is missing.
        '';
      };
      hfRepo = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Hugging Face repository (llama kind).";
      };
      quant = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Quantization taken from the repository (llama kind).";
      };
      hfFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "File to take from the repository, when it holds several (llama kind).";
      };
      kv = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "KV cache type of both caches (llama kind).";
      };
      mtp = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "The model ships multi-token prediction draft heads (llama kind).";
      };
      batchSize = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Logical batch size (llama kind).";
      };
      ubatchSize = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Physical batch size (llama kind).";
      };
      modelPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model path inside the container (sglang kind).";
      };
    };
  };

  strataFamily = config.lantian.strata.family;
  strataModel = config.lantian.strata.model;
  strataDataDir = "/var/cache/strata/data";
  strataGpus = config.lantian.strata.gpus;
  # only when asked for: "all" fails on a host with a single card to use
  strataGpuFlags = lib.optionalString (strataGpus != null) "--gpus ${strataGpus} ";

  # upstream ships the speed projection's control vector for qwen and coder only
  strataSpeedProjection =
    {
      qwen = "on";
      coder = "on";
      swift = "off";
      unsloth = "off";
    }
    .${strataFamily};

  # flags both the start and the setup take: setup is the same invocation
  # without a server to listen
  strataFlags = m: ''
    --yes --family ${strataFamily} --model ${strataModel} --backend cuda \
    --source huggingface --context ${toString m.ctxSize} --kv int8 --mtp on --parallel 1 \
    --vision ${
      if m.vision or false then "yes" else "no"
    } --experimental-speed-projection ${strataSpeedProjection} \
    --no-browser ${strataGpuFlags}--data-dir ${strataDataDir}'';

  provisioningOf =
    m:
    if (m.kind or "llama") == "strata" then
      {
        # setup.py writes strata-<family><size>.json into its data folder once
        # the model, its pack and its config are ready
        guard = "!/var/cache/strata/runtime/strata/strata-*.json";
        command = "${lib.getExe pkgs.nur-xddxdd.strata} ${strataFlags m} --no-start";
      }
    else if (m.kind or "llama") == "maya" then
      {
        guard = "!/var/cache/project-maya/data/project-maya/${config.lantian.maya.config}.json";
        command = ''
          ${lib.getExe pkgs.nur-xddxdd.project-maya} \
          --setup --yes --plain --download-model --model ${config.lantian.maya.model} \
          --models-dir /var/cache/project-maya/models --no-start
        '';
      }
    else
      null;

  cmdOf =
    m:
    let
      kind = m.kind or "llama";
      quant = m.quant or null;
      hfFile = m.hfFile or null;
      kv = m.kv or null;
      mode = m.mode or "chat";
      mtp = m.mtp or false;
      batchSize = m.batchSize or null;
      thinking = m.thinking or false;
      vision = m.vision or false;
    in
    if kind == "llama" then
      lib.concatStringsSep " " (
        [
          llama-server
          "--port \${PORT} --host 127.0.0.1"
          (if quant != null then "--hf-repo ${m.hfRepo}:${quant}" else "--hf-repo ${m.hfRepo}")
        ]
        ++ lib.optional (hfFile != null) "--hf-file ${hfFile}"
        ++ lib.optional (mode == "embeddings") "--embeddings --pooling last"
        ++ lib.optional (mode == "rerank") "--rerank"
        ++ lib.optional (kv != null) "--cache-type-k ${kv} --cache-type-v ${kv}"
        ++ lib.optional mtp "--spec-type draft-mtp --spec-draft-n-max 2"
        ++ [
          (
            "--ctx-size ${toString m.ctxSize}"
            + lib.optionalString (
              batchSize != null
            ) " --batch-size ${toString batchSize} --ubatch-size ${toString m.ubatchSize}"
          )
        ]
        ++ lib.optional thinking "--reasoning-preserve"
        ++ lib.optional vision "--image-min-tokens 1024"
      )
    else if kind == "sglang" then
      ''
        ${podman} --remote run --rm --replace --name ''${MODEL_ID} \
        --ipc=host --gpus=all \
        --publish=127.0.0.1:''${PORT}:''${PORT} \
        -e TORCHINDUCTOR_CACHE_DIR=/var/cache/torchinductor \
        -v /var/cache/huggingface:/root/.cache/huggingface \
        -v /var/cache/torchinductor:/var/cache/torchinductor \
        -v ${config.hardware.nvidia.package.stdenv.cc.libc.out}:${config.hardware.nvidia.package.stdenv.cc.libc.out}:ro \
        ${sglang-image} \
        python3 -m sglang.launch_server \
        --attention-backend=fa3 \
        --context-length=${toString m.ctxSize} \
        --disable-overlap \
        --disable-radix-cache \
        --enable-deterministic-inference \
        --enable-metrics \
        --enable-torch-compile \
        --host=0.0.0.0 \
        --mem-fraction-static=0.8 \
        --model-path=${m.modelPath} \
        --port=''${PORT} \
        --quantization=w8a8_int8 \
        --sleep-on-idle
      ''
    else if kind == "strata" then
      ''
        ${lib.getExe pkgs.nur-xddxdd.strata} ${strataFlags m} \
        --host 127.0.0.1 --port ''${PORT}
      ''
    else
      ''
        ${lib.getExe pkgs.nur-xddxdd.project-maya} \
        --config /var/cache/project-maya/data/project-maya/${config.lantian.maya.config}.json \
        --host 127.0.0.1 --port ''${PORT}
      '';

  registry = {
    # keep-sorted start block=yes
    "gemma4-26b-a4b" = {
      name = "Gemma 4 26B A4B";
      hfRepo = "huihui-ai/Huihui-gemma-4-26B-A4B-it-qat-q4_0-unquantized-abliterated-GGUF";
      quant = "Q4_0";
      kv = "q8_0";
      ctxSize = 256000;
      batchSize = 1024;
      ubatchSize = 512;
      maxTokens = 8192;
      minVramGB = 24;
    };
    "glm-5.3-flash" = {
      name = "GLM-5.3-Flash";
      kind = "maya";
      ctxSize = 32768;
      maxTokens = 8192;
      thinking = true;
      vision = true;
      minVramGB = 48;
    };
    "nomic-embed-code" = {
      name = "Nomic Embed Code";
      hfRepo = "nomic-ai/nomic-embed-code-GGUF";
      quant = if LT.this.vramGB <= 8 then "Q4_K_M" else "Q8_0";
      mode = "embeddings";
      ctxSize = 8192;
      batchSize = 2048;
      ubatchSize = 2048;
    };
    "qwen3-embedding-0.6b" = {
      name = "Qwen3 Embedding 0.6B";
      hfRepo = "Qwen/Qwen3-Embedding-0.6B-GGUF";
      quant = "F16";
      mode = "embeddings";
      ctxSize = 8192;
      batchSize = 2048;
      ubatchSize = 2048;
    };
    "qwen3-embedding-4b" = {
      name = "Qwen3 Embedding 4B";
      hfRepo = "Qwen/Qwen3-Embedding-4B-GGUF";
      quant = if LT.this.vramGB <= 8 then "Q8_0" else "F16";
      mode = "embeddings";
      ctxSize = 8192;
      batchSize = 2048;
      ubatchSize = 2048;
    };
    "qwen3-embedding-8b" = {
      name = "Qwen3 Embedding 8B";
      hfRepo = "Qwen/Qwen3-Embedding-8B-GGUF";
      quant = "Q8_0";
      mode = "embeddings";
      ctxSize = 8192;
      batchSize = 2048;
      ubatchSize = 2048;
      minVramGB = 24;
    };
    "qwen3-reranker-0.6b" = {
      name = "Qwen3 Reranker 0.6B";
      hfRepo = "mradermacher/Qwen3-Reranker-0.6B-GGUF";
      quant = "F16";
      mode = "rerank";
      ctxSize = 32768;
    };
    "qwen3-reranker-4b" = {
      name = "Qwen3 Reranker 4B";
      hfRepo = "mradermacher/Qwen3-Reranker-4B-GGUF";
      quant = if LT.this.vramGB <= 8 then "Q8_0" else "F16";
      mode = "rerank";
      ctxSize = 32768;
    };
    "qwen3-reranker-8b" = {
      name = "Qwen3 Reranker 8B";
      hfRepo = "QuantFactory/Qwen3-Reranker-8B-GGUF";
      quant = "Q8_0";
      mode = "rerank";
      ctxSize = 32768;
      minVramGB = 24;
    };
    "qwen3.6-35b-a3b" = {
      name = "Qwen3.6 35B A3B";
      hfRepo = "huihui-ai/Huihui-Qwen3.6-35B-A3B-abliterated-MTP-GGUF";
      hfFile = "Huihui-Qwen3.6-35B-A3B-abliterated-ggml-model-Q4_K.gguf";
      kv = "q8_0";
      mtp = true;
      ctxSize = 256000;
      batchSize = 1024;
      ubatchSize = 512;
      maxTokens = 8192;
      thinking = true;
      vision = true;
      minVramGB = 24;
    };
    "qwen3.8-27b" = {
      name = "Qwen3.8 27B";
      hfRepo = "huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF";
      hfFile = "Huihui-Qwen3.8-27B-abliterated-GSQ-RCO-IQ3_S-mtp.gguf";
      kv = "q4_0";
      mtp = true;
      ctxSize = 200000;
      batchSize = 1024;
      ubatchSize = 512;
      maxTokens = 8192;
      thinking = true;
      vision = true;
      minVramGB = 24;
    };
    "qwen3.8-flash-next" = {
      name = "Qwen3.8 Flash Next";
      kind = "strata";
      ctxSize = 262144;
      maxTokens = 8192;
      thinking = true;
      vision = true;
      minVramGB = 24;
    };
    "sakura-14b-qwen2.5-v1.0" = {
      name = "Sakura 14B Qwen2.5 v1.0";
      kind = "sglang";
      modelPath = "reinforce20001/SakuraLLM.Sakura-14B-Qwen2.5-v1.0-W8A8-Int8-V2";
      ctxSize = 4096;
      maxTokens = 2048;
      minVramGB = 24;
    };
    # keep-sorted end
  };
in
{
  options.lantian.strata.family = lib.mkOption {
    type = lib.types.enum [
      "qwen"
      "coder"
      "swift"
      "unsloth"
    ];
    default = "swift";
    description = ''
      Model family Strata serves: qwen, coder, swift or unsloth. The setup offers
      the quants that family has; the speed projection exists for qwen and coder
      only.
    '';
  };

  options.lantian.strata.gpus = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = ''
      Cards to split the model across, as nvidia-smi numbers them, for example
      "all" or "0,1". Null lets Strata pick the card it fits on; "all" needs two
      cards Strata can use together and fails setup on a single-card host.
    '';
  };

  options.lantian.strata.model = lib.mkOption {
    type = lib.types.str;
    default = "IQ3_S";
    description = ''
      Quantization of the model to run.
      The default IQ3_S is the 3.5-bit GSQ-RCO pick.
    '';
  };

  options.lantian.maya.model = lib.mkOption {
    type = lib.types.str;
    default = "glm-maya-s";
    description = ''
      Setup id of the Maya quant to provision: the --model a --setup run takes.
    '';
  };

  options.lantian.maya.config = lib.mkOption {
    type = lib.types.str;
    default = "maya-maya-s-v2-iq2_xxs";
    description = ''
      The Project Maya config to start, without .json, as the model's setup
      wrote it under data/project-maya: maya- plus the quant's key.
    '';
  };

  options.lantian.llama-swap.models = lib.mkOption {
    type = lib.types.attrsOf modelType;
    default = { };
    description = ''
      Models available through llama-swap, keyed by model id. The llama-swap
      module serves the entries whose _cmd is not null, and clients that need to
      know the models (pi) read the same entries.
    '';
  };

  config.lantian.llama-swap.models = lib.mapAttrs (
    _: m:
    let
      enabled = (m.minVramGB or 0) <= LT.this.vramGB;
      provisioning = provisioningOf m;
    in
    m
    // {
      _cmd = if enabled then cmdOf m else null;
      _provision = if enabled && provisioning != null then provisioning.command else null;
      _provisionGuard = if enabled && provisioning != null then provisioning.guard else null;
    }
  ) registry;
}
