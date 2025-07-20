{
  LT,
  lib,
  config,
  ...
}:
let
  osConfig = config;

  providerTags = {
    # Base priorities
    free = 10;
    free_third_party = 20;
    free_unreliable = 30;
    paid = 40;

    # Modifiers
    slow = 1;
    context_limit = 1;
  };

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
        engine = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        apiKeyPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = osConfig.age.secrets."uni-api-${config.name}-api-key".path;
        };
        cloudflareAccountIdPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        providerTags = lib.mkOption {
          type = lib.types.listOf (lib.types.enum (builtins.attrNames providerTags));
        };
        modelJsonFile = lib.mkOption {
          type = lib.types.path;
          default = ./apis + "/${config.name}.json";
        };
        modelAsDefault = lib.mkOption {
          type = lib.types.bool;
          default = config.providerTags == [ "free" ] || config.providerTags == [ "paid" ];
        };

        _models = lib.mkOption {
          readOnly = true;
          default = lib.flatten (
            lib.mapAttrsToList (
              k: v:
              let
                modelNameWithSuffix =
                  if lib.hasInfix ":" v then
                    lib.replaceStrings [ ":" ] [ ":${config.name}-" ] v
                  else
                    "${v}:${config.name}";
              in
              [
                (lib.nameValuePair k modelNameWithSuffix)
              ]
              ++ lib.optionals config.modelAsDefault [
                (lib.nameValuePair k v)
              ]
            ) (lib.importJSON config.modelJsonFile)
          );
        };
        _score = lib.mkOption {
          readOnly = true;
          default = LT.math.sum (builtins.map (n: providerTags."${n}") config.providerTags);
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
      providerTags = [ "free" ];
    }
    {
      name = "mistral";
      baseURL = "https://api.mistral.ai/v1/chat/completions";
      providerTags = [ "free" ];
    }
    {
      name = "google";
      baseURL = "https://generativelanguage.googleapis.com/v1beta";
      engine = "gemini";
      providerTags = [ "free" ];
    }
    {
      name = "github-models";
      baseURL = "https://models.inference.ai.azure.com/chat/completions";
      providerTags = [ "free" ];
    }
    {
      name = "lingyiwanwu";
      baseURL = "https://api.lingyiwanwu.com/v1/chat/completions";
      providerTags = [ "free" ];
    }
    {
      # https://docs.api.ecylt.top/wbot/wbot-4-347b
      name = "wbot";
      baseURL = "https://api.223387.xyz/v1/chat/completions";
      providerTags = [ "free" ];
    }

    # Third party free providers
    {
      name = "cerebras";
      baseURL = "https://api.cerebras.ai/v1/chat/completions";
      providerTags = [ "free_third_party" ];
    }
    {
      name = "chutes-ai";
      baseURL = "https://llm.chutes.ai/v1/chat/completions";
      providerTags = [ "free_third_party" ];
    }
    {
      name = "pollinations";
      baseURL = "https://text.pollinations.ai/openai/chat/completions";
      apiKeyPath = null;
      providerTags = [ "free_third_party" ];
    }
    {
      name = "akash-networks";
      baseURL = "https://chatapi.akash.network/api/v1/chat/completions";
      providerTags = [ "free_third_party" ];
    }
    {
      name = "cloudflare";
      baseURL = null;
      apiKeyPath = config.age.secrets.uni-api-cloudflare-api-key.path;
      cloudflareAccountIdPath = config.age.secrets.uni-api-cloudflare-account-id.path;
      providerTags = [
        "free_third_party"
        "slow"
      ];
    }
    {
      name = "modelscope";
      baseURL = "https://api-inference.modelscope.cn/v1/chat/completions";
      providerTags = [ "free_third_party" ];
    }
    {
      name = "nvidia";
      baseURL = "https://integrate.api.nvidia.com/v1/chat/completions";
      providerTags = [
        "free_third_party"
        "context_limit"
      ];
    }

    # Less reliable free providers
    {
      name = "veloera";
      baseURL = "https://zone.veloera.org/v1/chat/completions";
      providerTags = [ "free_unreliable" ];
    }

    # Paid providers
    {
      name = "openrouter";
      baseURL = "https://openrouter.ai/api/v1/chat/completions";
      engine = "openrouter";
      providerTags = [ "paid" ];
    }
    {
      name = "xai";
      baseURL = "https://api.x.ai/v1/chat/completions";
      providerTags = [ "paid" ];
    }
    {
      name = "siliconflow";
      baseURL = "https://api.siliconflow.cn/v1/chat/completions";
      providerTags = [
        "paid"
        "context_limit"
      ];
    }
  ];
}
