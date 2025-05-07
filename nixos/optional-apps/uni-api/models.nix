{
  lib,
  config,
  ...
}:
let
  modelOptions =
    { config, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
        };
        baseURL = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
        };
        apiKeyPath = lib.mkOption {
          type = lib.types.str;
        };
        cloudflareAccountIdPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        modelJsonFile = lib.mkOption {
          type = lib.types.path;
          default = ./apis + "/${config.name}.json";
        };
        modelSuffix = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = config.name;
        };

        models = lib.mkOption {
          readOnly = true;
          default = lib.mapAttrs (
            _k: v:
            if config.modelSuffix == null then
              v
            else if lib.hasInfix ":" v then
              lib.replaceStrings [ ":" ] [ ":${config.modelSuffix}-" ] v
            else
              "${v}:${config.modelSuffix}"
          ) (lib.importJSON config.modelJsonFile);
        };
      };
    };
in
{
  options.lantian.llm-providers = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule modelOptions);
    default = [ ];
  };

  config.lantian.llm-providers = [
    # Free providers
    {
      name = "groq";
      baseURL = "https://api.groq.com/openai/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-groq-api-key.path;
      modelSuffix = null;
    }
    {
      name = "mistral";
      baseURL = "https://api.mistral.ai/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-mistral-api-key.path;
      modelSuffix = null;
    }
    {
      name = "gemini";
      baseURL = "https://generativelanguage.googleapis.com/v1beta";
      apiKeyPath = config.age.secrets.uni-api-google-api-key.path;
      modelJsonFile = ./apis/google.json;
      modelSuffix = null;
    }
    {
      # $150 free credit per month
      name = "xai";
      baseURL = "https://api.x.ai/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-xai-api-key.path;
      modelSuffix = null;
    }
    {
      name = "cloudflare";
      baseURL = null;
      apiKeyPath = config.age.secrets.uni-api-cloudflare-api-key.path;
      cloudflareAccountIdPath = config.age.secrets.uni-api-cloudflare-account-id.path;
      # Latency is high
      modelSuffix = "cloudflare";
    }
    {
      name = "github-models";
      baseURL = "https://models.inference.ai.azure.com/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-github-models-api-key.path;
      modelSuffix = null;
    }
    {
      name = "lingyiwanwu";
      baseURL = "https://api.lingyiwanwu.com/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-lingyiwanwu-api-key.path;
    }
    {
      name = "chutes-ai";
      baseURL = "https://llm.chutes.ai/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-chutes-ai-api-key.path;
    }
    {
      name = "pollinations";
      baseURL = "https://text.pollinations.ai/openai/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-chutes-ai-api-key.path;
    }
    {
      name = "akash-networks";
      baseURL = "https://chatapi.akash.network/api/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-akash-networks-api-key.path;
    }
    {
      name = "modelscope";
      baseURL = "https://api-inference.modelscope.cn/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-modelscope-api-key.path;
    }
    {
      name = "nvidia";
      baseURL = "https://integrate.api.nvidia.com/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-nvidia-api-key.path;
    }
    {
      # https://docs.api.ecylt.top/wbot/wbot-4-347b
      name = "wbot";
      baseURL = "https://api.223387.xyz/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-wbot-api-key.path;
      modelSuffix = null;
    }
    # Third party free providers
    {
      name = "ai-985-games";
      baseURL = "https://ai.985.games/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-ai-985-games-api-key.path;
      modelSuffix = null;
    }

    # Paid providers
    {
      name = "openrouter";
      baseURL = "https://openrouter.ai/api/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-openrouter-api-key.path;
      modelSuffix = null;
    }
    {
      name = "siliconflow";
      baseURL = "https://api.siliconflow.cn/v1/chat/completions";
      apiKeyPath = config.age.secrets.uni-api-siliconflow-api-key.path;
      # Siliconflow may truncate long responses
    }
  ];
}
