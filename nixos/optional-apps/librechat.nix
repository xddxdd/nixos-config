{
  LT,
  lib,
  config,
  inputs,
  ...
}:
let
  models = lib.unique (
    lib.flatten (
      builtins.map (provider: builtins.map (v: v.value) provider._models) config.lantian.llm-providers
    )
  );
in
{
  imports = [
    ./mongodb.nix
    ./uni-api
  ];

  age.secrets.librechat-creds-key.file = inputs.secrets + "/librechat-creds-key.age";
  age.secrets.librechat-creds-iv.file = inputs.secrets + "/librechat-creds-iv.age";
  age.secrets.librechat-jwt-secret.file = inputs.secrets + "/librechat-jwt-secret.age";
  age.secrets.librechat-jwt-refresh-secret.file =
    inputs.secrets + "/librechat-jwt-refresh-secret.age";
  age.secrets.librechat-openid-client-secret.file = inputs.secrets + "/dex/librechat-secret.age";
  age.secrets.librechat-openid-session-secret.file =
    inputs.secrets + "/librechat-openid-session-secret.age";
  age.secrets.librechat-uni-api-secret.file = inputs.secrets + "/uni-api/keys/admin-api-key.age";

  services.librechat = {
    enable = true;
    port = LT.port.Librechat;
    env = {
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
    };
    credentials = {
      CREDS_KEY = config.age.secrets.librechat-creds-key.path;
      CREDS_IV = config.age.secrets.librechat-creds-iv.path;
      JWT_SECRET = config.age.secrets.librechat-jwt-secret.path;
      JWT_REFRESH_SECRET = config.age.secrets.librechat-jwt-refresh-secret.path;
      OPENID_CLIENT_SECRET = config.age.secrets.librechat-openid-client-secret.path;
      OPENID_SESSION_SECRET = config.age.secrets.librechat-openid-session-secret.path;
      UNI_API_KEY = config.age.secrets.librechat-uni-api-secret.path;
    };
    settings = {
      version = "1.2.5";
      cache = true;
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
    };
  };

  lantian.nginxVhosts = {
    "ai.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://[::1]:${LT.portStr.Librechat}";
        };
      };

      sslCertificate = "zerossl-xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
