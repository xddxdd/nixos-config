{
  inputs,
  pkgs,
  LT,
  config,
  utils,
  ...
}:
let
  cfg = {
    providers = [
      # Free providers
      {
        provider = "groq";
        base_url = "https://api.groq.com/openai/v1/chat/completions";
        api = {
          _secret = config.age.secrets.groq-api-key.path;
        };
      }
      {
        provider = "mistral";
        base_url = "https://api.mistral.ai/v1/chat/completions";
        api = {
          _secret = config.age.secrets.mistral-api-key.path;
        };
      }
      # Paid providers
      # {
      #   provider = "novita";
      #   base_url = "https://api.novita.ai/v3/openai/chat/completions";
      #   api = {
      #     _secret = config.age.secrets.novita-api-key.path;
      #   };
      # }
      {
        provider = "openrouter";
        base_url = "https://openrouter.ai/api/v1/chat/completions";
        api = {
          _secret = config.age.secrets.openrouter-api-key.path;
        };
      }
      {
        provider = "siliconflow";
        base_url = "https://api.siliconflow.cn/v1/chat/completions";
        api = {
          _secret = config.age.secrets.siliconflow-api-key.path;
        };
      }
    ];
    api_keys = [
      {
        api = {
          _secret = config.age.secrets.admin-api-key.path;
        };
        role = "admin";
      }
    ];
  };
in
{
  age.secrets.novita-api-key = {
    file = inputs.secrets + "/uni-api/novita-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.openrouter-api-key = {
    file = inputs.secrets + "/uni-api/openrouter-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.siliconflow-api-key = {
    file = inputs.secrets + "/uni-api/siliconflow-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.mistral-api-key = {
    file = inputs.secrets + "/uni-api/mistral-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.groq-api-key = {
    file = inputs.secrets + "/uni-api/groq-api-key.age";
    owner = "uni-api";
    group = "uni-api";
  };
  age.secrets.admin-api-key = {
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
