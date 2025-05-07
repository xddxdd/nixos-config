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
  cfg = import ./models.nix { inherit lib config; };
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
        "akash-networks-api-key"
        "chutes-ai-api-key"
        "cloudflare-account-id"
        "cloudflare-api-key"
        "github-models-api-key"
        "google-api-key"
        "groq-api-key"
        "lingyiwanwu-api-key"
        "mistral-api-key"
        "modelscope-api-key"
        "nvidia-api-key"
        "openrouter-api-key"
        "siliconflow-api-key"
        "siliconflow-pool-api-key"
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
