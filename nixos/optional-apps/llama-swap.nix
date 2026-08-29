{
  lib,
  pkgs,
  LT,
  ...
}:
let
  llama-cpp = pkgs.llama-cpp.override { cudaSupport = true; };
  llama-server = lib.getExe' llama-cpp "llama-server";

  mkEmbedding = repo: quant: ''
    ${llama-server} --port ''${PORT} --host 127.0.0.1 \
    --hf-repo ${repo}:${quant} \
    --embeddings --pooling last \
    --ctx-size 8192 --batch-size 2048 --ubatch-size 2048
  '';

  mkReranker = repo: quant: ''
    ${llama-server} --port ''${PORT} --host 127.0.0.1 \
    --hf-repo ${repo}:${quant} \
    --rerank --ctx-size 32768
  '';

  # Model IDs (API-facing names) must always be lower case; display `name`s use proper casing
  models = {
    # keep-sorted start block=yes
    "nomic-embed-code" = {
      name = "Nomic Embed Code";
      cmd = mkEmbedding "nomic-ai/nomic-embed-code-GGUF" (
        if LT.this.vramGB <= 8 then "Q4_K_M" else "Q8_0"
      );
    };
    "qwen3-embedding-0.6b" = {
      name = "Qwen3 Embedding 0.6B";
      cmd = mkEmbedding "Qwen/Qwen3-Embedding-0.6B-GGUF" "F16";
    };
    "qwen3-embedding-4b" = {
      name = "Qwen3 Embedding 4B";
      cmd = mkEmbedding "Qwen/Qwen3-Embedding-4B-GGUF" (if LT.this.vramGB <= 8 then "Q8_0" else "F16");
    };
    "qwen3-reranker-0.6b" = {
      name = "Qwen3 Reranker 0.6B";
      cmd = mkReranker "mradermacher/Qwen3-Reranker-0.6B-GGUF" "F16";
    };
    "qwen3-reranker-4b" = {
      name = "Qwen3 Reranker 4B";
      cmd = mkReranker "mradermacher/Qwen3-Reranker-4B-GGUF" (
        if LT.this.vramGB <= 8 then "Q8_0" else "F16"
      );
    };
    # keep-sorted end
  }
  // lib.optionalAttrs (LT.this.vramGB >= 24) {
    # keep-sorted start block=yes
    "qwen3-embedding-8b" = {
      name = "Qwen3 Embedding 8B";
      cmd = mkEmbedding "Qwen/Qwen3-Embedding-8B-GGUF" "Q8_0";
    };
    "qwen3-reranker-8b" = {
      name = "Qwen3 Reranker 8B";
      cmd = mkReranker "QuantFactory/Qwen3-Reranker-8B-GGUF" "Q8_0";
    };
    "qwen3.8-27b" = {
      name = "Qwen3.8 27B";
      cmd = ''
        ${llama-server} --port ''${PORT} --host 127.0.0.1 \
        --hf-repo unsloth/Qwen3.8-27B-GGUF:UD-IQ4_XS \
        --mmproj-url https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/main/mmproj-F16.gguf \
        --cache-type-k q4_0 --cache-type-v q4_0 \
        --spec-type draft-mtp --spec-draft-n-max 2 \
        --ctx-size 128000 --batch-size 1024 --ubatch-size 512 \
        --image-min-tokens 1024
      '';
    };
    # keep-sorted end
  };
in
{
  imports = [ ./llama-cpp.nix ];

  assertions = [
    {
      assertion = LT.this.vramGB > 0;
      message = "llama-swap requires vramGB > 0";
    }
  ];

  services.llama-swap = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = LT.port.LlamaSwap;

    settings = {
      globalTTL = 600;
      healthCheckTimeout = 600;
      inherit models;
      routing.router.settings.groups.single = {
        swap = true;
        exclusive = true;
        members = builtins.attrNames models;
      };
    };
  };

  systemd.services.llama-swap.serviceConfig = {
    User = "llama-swap";
    Group = "llama-swap";
    DynamicUser = lib.mkForce false;
  };

  users.users.llama-swap = {
    group = "llama-swap";
    isSystemUser = true;
  };
  users.groups.llama-swap = { };

  lantian.localVhosts."llama-swap" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.LlamaSwap}";
      proxyNoTimeout = true;
    };
  };
}
