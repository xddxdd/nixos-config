{
  inputs,
  pkgs,
  lib,
  LT,
  config,
  utils,
  ...
}:
let
  cloudflareModels = [
    "@hf/thebloke/deepseek-coder-6.7b-base-awq"
    "@hf/thebloke/deepseek-coder-6.7b-instruct-awq"
    "@cf/deepseek-ai/deepseek-math-7b-instruct"
    "@cf/thebloke/discolm-german-7b-v1-awq"
    "@cf/tiiuae/falcon-7b-instruct"
    "@hf/google/gemma-7b-it"
    "@hf/nousresearch/hermes-2-pro-mistral-7b"
    "@hf/thebloke/llama-2-13b-chat-awq"
    "@cf/meta/llama-2-7b-chat-fp16"
    "@cf/meta/llama-2-7b-chat-int8"
    "@cf/meta/llama-3-8b-instruct"
    "@cf/meta/llama-3-8b-instruct-awq"
    "@cf/meta/llama-3.1-8b-instruct"
    "@cf/meta/llama-3.1-8b-instruct-awq"
    "@cf/meta/llama-3.1-8b-instruct-fp8"
    "@cf/meta/llama-3.2-11b-vision-instruct"
    "@cf/meta/llama-3.2-1b-instruct"
    "@cf/meta/llama-3.2-3b-instruct"
    "@hf/thebloke/llamaguard-7b-awq"
    "@hf/meta-llama/meta-llama-3-8b-instruct"
    "@cf/mistral/mistral-7b-instruct-v0.1"
    "@hf/thebloke/mistral-7b-instruct-v0.1-awq"
    "@hf/mistral/mistral-7b-instruct-v0.2"
    "@hf/thebloke/neural-chat-7b-v3-1-awq"
    "@cf/openchat/openchat-3.5-0106"
    "@hf/thebloke/openhermes-2.5-mistral-7b-awq"
    "@cf/microsoft/phi-2"
    "@cf/qwen/qwen1.5-0.5b-chat"
    "@cf/qwen/qwen1.5-1.8b-chat"
    "@cf/qwen/qwen1.5-14b-chat-awq"
    "@cf/qwen/qwen1.5-7b-chat-awq"
    "@cf/defog/sqlcoder-7b-2"
    "@hf/nexusflow/starling-lm-7b-beta"
    "@cf/tinyllama/tinyllama-1.1b-chat-v1.0"
    "@cf/fblgit/una-cybertron-7b-v2-bf16"
    "@hf/thebloke/zephyr-7b-beta-awq"
  ];

  loadModels = f: lib.mapAttrsToList (k: v: { "${k}" = v; }) (lib.importJSON f);

  cfg = {
    providers = [
      # Free providers
      {
        provider = "groq";
        base_url = "https://api.groq.com/openai/v1/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-groq-api-key.path;
        };
        model = loadModels ./apis/groq.json;
      }
      {
        provider = "mistral";
        base_url = "https://api.mistral.ai/v1/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-mistral-api-key.path;
        };
        model = loadModels ./apis/mistral.json;
      }
      {
        provider = "cloudflare";
        api = {
          _secret = config.age.secrets.uni-api-cloudflare-api-key.path;
        };
        cf_account_id = {
          _secret = config.age.secrets.uni-api-cloudflare-account-id.path;
        };
        model = builtins.map (v: {
          "${v}" = lib.removePrefix "@cf/" (lib.removePrefix "@hf/" v);
        }) cloudflareModels;
      }
      # Paid providers
      {
        provider = "novita";
        base_url = "https://api.novita.ai/v3/openai/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-novita-api-key.path;
        };
        model = loadModels ./apis/novita.json;
      }
      {
        provider = "openrouter";
        base_url = "https://openrouter.ai/api/v1/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-openrouter-api-key.path;
        };
        model = loadModels ./apis/openrouter.json;
      }
      {
        provider = "siliconflow";
        base_url = "https://api.siliconflow.cn/v1/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-siliconflow-api-key.path;
        };
        model = loadModels ./apis/siliconflow.json;
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
  };
in
{
  age.secrets.uni-api-novita-api-key = {
    file = inputs.secrets + "/uni-api/novita-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.uni-api-openrouter-api-key = {
    file = inputs.secrets + "/uni-api/openrouter-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.uni-api-siliconflow-api-key = {
    file = inputs.secrets + "/uni-api/siliconflow-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.uni-api-mistral-api-key = {
    file = inputs.secrets + "/uni-api/mistral-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.uni-api-groq-api-key = {
    file = inputs.secrets + "/uni-api/groq-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.uni-api-cloudflare-account-id = {
    file = inputs.secrets + "/uni-api/cloudflare-account-id.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.uni-api-cloudflare-api-key = {
    file = inputs.secrets + "/uni-api/cloudflare-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.uni-api-admin-api-key = {
    file = inputs.secrets + "/uni-api/admin-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };

  systemd.services.uni-api = {
    description = "Uni-API Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      DISABLE_DATABASE = "true";
      UVICORN_HOST = "127.0.0.1";
      UVICORN_PORT = LT.portStr.UniAPI;
    };

    script = ''
      ${utils.genJqSecretsReplacementSnippet cfg "api.yaml"}
      exec ${pkgs.nur-xddxdd.uni-api}/bin/uni-api
    '';

    postStart = ''
      ${pkgs.curl}/bin/curl \
        --fail \
        --retry 10 \
        --retry-delay 5 \
        --retry-max-time 60 \
        --retry-all-errors \
        -H "Authorization: Bearer $(cat ${config.age.secrets.uni-api-admin-api-key.path})" \
        http://uni-api.localhost/v1/models
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";

      RuntimeDirectory = "uni-api";
      WorkingDirectory = "/run/uni-api";

      User = "uni-api";
      Group = "uni-api";
    };
  };

  users.users.uni-api = {
    group = "uni-api";
    isSystemUser = true;
  };
  users.groups.uni-api.members = [ "nginx" ];

  # Workaround for Open WebUI DNS issue
  networking.hosts."127.0.0.1" = [ "uni-api.localhost" ];

  lantian.nginxVhosts = {
    "uni-api.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.UniAPI}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "uni-api.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.UniAPI}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
