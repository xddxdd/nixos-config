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
  loadModels = providerName: f: loadModels' providerName (lib.importJSON f);
  loadModels' =
    providerName:
    lib.mapAttrsToList (
      k: v: {
        "${k}" =
          if providerName == null then
            v
          else if lib.hasInfix ":" v then
            lib.replaceStrings [ ":" ] [ ":${providerName}-" ]
          else
            "${v}:${providerName}";
      }
    );

  uni-api = pkgs.nur-xddxdd.uni-api.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../../patches/uni-api-speedup.patch
    ];
  });

  cfg = {
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
        provider = "lingyiwanwu";
        base_url = "https://api.lingyiwanwu.com/v1/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-lingyiwanwu-api-key.path;
        };
        model = loadModels "lingyiwanwu" ./apis/lingyiwanwu.json;
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
      {
        provider = "siliconflow-pool";
        base_url = "http://api.888188.me/v1/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-siliconflow-pool-api-key.path;
        };
        # Siliconflow may truncate long responses
        model = loadModels "siliconflow" ./apis/siliconflow.json;
      }
      {
        provider = "smnet-free-chat";
        base_url = "https://api-1-hemf.onrender.com/v1/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-smnet-free-chat-api-key.path;
        };
        model = loadModels null ./apis/smnet-free-chat.json;
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
      {
        provider = "novita";
        base_url = "https://api.novita.ai/v3/openai/chat/completions";
        api = {
          _secret = config.age.secrets.uni-api-novita-api-key.path;
        };
        # Novita is expensive
        model = loadModels "novita" ./apis/novita.json;
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
  age.secrets = builtins.listToAttrs (
    builtins.map
      (
        f:
        lib.nameValuePair "uni-api-${f}" {
          file = inputs.secrets + "/uni-api/${f}.age";
          owner = "uni-api";
          group = "uni-api";
        }
      )
      [
        "admin-api-key"
        "ai-985-games-api-key"
        "cloudflare-account-id"
        "cloudflare-api-key"
        "google-api-key"
        "groq-api-key"
        "lingyiwanwu-api-key"
        "mistral-api-key"
        "novita-api-key"
        "openrouter-api-key"
        "siliconflow-api-key"
        "siliconflow-pool-api-key"
        "smnet-free-chat-api-key"
        "wbot-api-key"
        "xai-api-key"
      ]
  );

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
      exec ${uni-api}/bin/uni-api
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
