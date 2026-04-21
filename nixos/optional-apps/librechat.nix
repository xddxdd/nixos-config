{
  LT,
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  models = lib.unique (
    lib.concatMap (provider: builtins.map (v: v.value) provider._models) config.lantian.llm-providers
  );
in
{
  imports = [
    ../client-apps/mcp-servers.nix
    ./mongodb.nix
    ./uni-api
  ];

  sops.secrets.librechat-creds-key.sopsFile = inputs.secrets + "/librechat.yaml";
  sops.secrets.librechat-creds-iv.sopsFile = inputs.secrets + "/librechat.yaml";
  sops.secrets.librechat-jwt-secret.sopsFile = inputs.secrets + "/librechat.yaml";
  sops.secrets.librechat-jwt-refresh-secret.sopsFile = inputs.secrets + "/librechat.yaml";
  sops.secrets.librechat-openid-client-secret = {
    sopsFile = inputs.secrets + "/common/dex.yaml";
    key = "dex-librechat-secret";
  };
  sops.secrets.librechat-openid-session-secret.sopsFile = inputs.secrets + "/librechat.yaml";
  sops.secrets.librechat-uni-api-secret = {
    sopsFile = inputs.secrets + "/uni-api/keys.yaml";
    key = "uni-api-admin-api-key";
  };

  services.librechat = {
    enable = true;
    env = {
      HOST = "127.0.0.1";
      PORT = LT.portStr.Librechat;

      MONGO_URI = "mongodb://127.0.0.1:27017/LibreChat";
      OPENID_ISSUER = "https://login.lantian.pub";
      OPENID_CLIENT_ID = "librechat";
      OPENID_CALLBACK_URL = "/oauth/openid/callback";
      OPENID_SCOPE = "openid profile email groups";
      OPENID_USE_END_SESSION_ENDPOINT = "true";
      OPENID_ADMIN_ROLE = "admin";
      OPENID_ADMIN_ROLE_PARAMETER_PATH = "groups";
      OPENID_ADMIN_ROLE_TOKEN_KIND = "id";

      ALLOW_EMAIL_LOGIN = "false";
      ALLOW_REGISTRATION = "false";
      ALLOW_SOCIAL_LOGIN = "true";
      ALLOW_SOCIAL_REGISTRATION = "true";

      DOMAIN_CLIENT = "https://ai.xuyh0120.win";
      DOMAIN_SERVER = "https://ai.xuyh0120.win";

      # Avoid duplicate compression
      DISABLE_COMPRESSION = "true";
    };
    credentials = {
      CREDS_KEY = config.sops.secrets.librechat-creds-key.path;
      CREDS_IV = config.sops.secrets.librechat-creds-iv.path;
      JWT_SECRET = config.sops.secrets.librechat-jwt-secret.path;
      JWT_REFRESH_SECRET = config.sops.secrets.librechat-jwt-refresh-secret.path;
      OPENID_CLIENT_SECRET = config.sops.secrets.librechat-openid-client-secret.path;
      OPENID_SESSION_SECRET = config.sops.secrets.librechat-openid-session-secret.path;
      UNI_API_KEY = config.sops.secrets.librechat-uni-api-secret.path;
    };
    settings = {
      version = "1.2.5";
      cache = true;
      interface = {
        runCode = false;
        webSearch = false;
      };
      endpoints = {
        custom = [
          {
            name = "UniAPI";
            apiKey = "\${UNI_API_KEY}";
            baseURL = "http://uni-api.localhost/v1";
            models = {
              default = models;
              fetch = false;
            };
          }
        ];
      };
      inherit (config.lantian.mcp) mcpServers;
    };
  };

  systemd.services.librechat = {
    path = [
      pkgs.bash
      pkgs.nodejs
      pkgs.python3
      pkgs.uv
    ];
    environment.HOME = "/var/cache/librechat";
    serviceConfig.CacheDirectory = "librechat";
  };

  lantian.nginxVhosts = {
    "ai.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Librechat}";
        };
      };

      sslCertificate = "zerossl-xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
