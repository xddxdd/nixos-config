{
  pkgs,
  lib,
  LT,
  config,
  utils,
  ...
}:
let
  uniApiConfig = {
    providers = builtins.map (
      v:
      {
        provider = v.name;
        api = if v.apiKeyPath != null then { _secret = v.apiKeyPath; } else "sk-123456";
        model = builtins.map (m: {
          "${m.name}" = m.value;
        }) v._models;
      }
      // (lib.optionalAttrs (v.baseURL != null) {
        base_url = v.baseURL;
      })
      // (lib.optionalAttrs (v.cloudflareAccountIdPath != null) {
        cf_account_id._secret = v.cloudflareAccountIdPath;
      })
      // (lib.optionalAttrs (v.engine != null) {
        inherit (v) engine;
      })
    ) (builtins.sort (a: b: a._score < b._score) config.lantian.llm-providers);

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
  imports = [ ./model-config.nix ];

  systemd.services.uni-api = {
    description = "Uni-API Server";
    after = [
      "network.target"
      "agenix-install-secrets.service"
    ];
    requires = [ "agenix-install-secrets.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      DISABLE_DATABASE = "true";
      UVICORN_HOST = "127.0.0.1";
      UVICORN_PORT = LT.portStr.UniAPI;
    };

    script = ''
      ${utils.genJqSecretsReplacementSnippet uniApiConfig "api.yaml"}
      exec ${pkgs.nur-xddxdd.uni-api}/bin/uni-api
    '';

    postStart = ''
      ${lib.getExe pkgs.curl} -fsSL \
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

  lantian.nginxVhosts = {
    "uni-api.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.UniAPI}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
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
