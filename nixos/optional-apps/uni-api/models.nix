{
  lib,
  config,
  ...
}:
let
  loadModels = providerName: f: loadModels' providerName (lib.importJSON f);
  loadModels' =
    providerName:
    lib.mapAttrsToList (
      k: v: {
        "${k}" =
          if providerName == null then
            v
          else if lib.hasInfix ":" v then
            lib.replaceStrings [ ":" ] [ ":${providerName}-" ] v
          else
            "${v}:${providerName}";
      }
    );
in
{
  providers = [
    # Free providers
    {
      provider = "groq";
      base_url = "https://api.groq.com/openai/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-groq-api-key.path;
      };
      model = loadModels null ./apis/groq.json;
    }
    {
      provider = "mistral";
      base_url = "https://api.mistral.ai/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-mistral-api-key.path;
      };
      model = loadModels null ./apis/mistral.json;
    }
    {
      provider = "gemini";
      base_url = "https://generativelanguage.googleapis.com/v1beta";
      api = {
        _secret = config.age.secrets.uni-api-google-api-key.path;
      };
      model = loadModels null ./apis/google.json;
    }
    {
      # $150 free credit per month
      provider = "xai";
      base_url = "https://api.x.ai/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-xai-api-key.path;
      };
      model = loadModels null ./apis/xai.json;
    }
    {
      provider = "cloudflare";
      api = {
        _secret = config.age.secrets.uni-api-cloudflare-api-key.path;
      };
      cf_account_id = {
        _secret = config.age.secrets.uni-api-cloudflare-account-id.path;
      };
      # Latency is high
      model = loadModels "cloudflare" ./apis/cloudflare.json;
    }
    {
      provider = "github-models";
      base_url = "https://models.inference.ai.azure.com/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-github-models-api-key.path;
      };
      model = loadModels null ./apis/github-models.json;
    }
    {
      provider = "lingyiwanwu";
      base_url = "https://api.lingyiwanwu.com/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-lingyiwanwu-api-key.path;
      };
      model = loadModels "lingyiwanwu" ./apis/lingyiwanwu.json;
    }
    {
      provider = "chutes-ai";
      base_url = "https://llm.chutes.ai/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-chutes-ai-api-key.path;
      };
      model = loadModels "chutes-ai" ./apis/chutes-ai.json;
    }
    {
      provider = "pollinations";
      base_url = "https://text.pollinations.ai/openai/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-chutes-ai-api-key.path;
      };
      model = loadModels "pollinations" ./apis/pollinations.json;
    }
    {
      provider = "akash-networks";
      base_url = "https://chatapi.akash.network/api/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-akash-networks-api-key.path;
      };
      model = loadModels "akash-networks" ./apis/akash-networks.json;
    }
    {
      provider = "modelscope";
      base_url = "https://api-inference.modelscope.cn/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-modelscope-api-key.path;
      };
      model = loadModels "modelscope" ./apis/modelscope.json;
    }
    {
      provider = "nvidia";
      base_url = "https://integrate.api.nvidia.com/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-nvidia-api-key.path;
      };
      model = loadModels "nvidia" ./apis/nvidia.json;
    }
    {
      # https://docs.api.ecylt.top/wbot/wbot-4-347b
      provider = "wbot";
      base_url = "https://api.223387.xyz/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-wbot-api-key.path;
      };
      model = loadModels null ./apis/wbot.json;
    }
    # Third party free providers
    {
      provider = "ai-985-games";
      base_url = "https://ai.985.games/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-ai-985-games-api-key.path;
      };
      model = loadModels null ./apis/ai-985-games.json;
    }

    # Paid providers
    {
      provider = "openrouter";
      base_url = "https://openrouter.ai/api/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-openrouter-api-key.path;
      };
      model = loadModels null ./apis/openrouter.json;
    }
    {
      provider = "siliconflow";
      base_url = "https://api.siliconflow.cn/v1/chat/completions";
      api = {
        _secret = config.age.secrets.uni-api-siliconflow-api-key.path;
      };
      # Siliconflow may truncate long responses
      model = loadModels "siliconflow" ./apis/siliconflow.json;
    }
  ];
  api_keys = [
    {
      api = {
        _secret = config.age.secrets.uni-api-admin-api-key.path;
      };
      role = "admin";
    }
  ];
}
