{
  LT,
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ ./uni-api ];

  age.secrets.open-webui-env.file = inputs.secrets + "/open-webui-env.age";

  services.open-webui = {
    enable = true;
    package = inputs.nixpkgs-stable.legacyPackages."${pkgs.system}".open-webui;
    port = LT.port.OpenWebUI;
    environmentFile = config.age.secrets.open-webui-env.path;
    environment = {
      ENV = "prod";
      OLLAMA_API_BASE_URL = "https://ollama.lt-home-vm.xuyh0120.win";
      WEBUI_URL = "https://open-webui.xuyh0120.win";
      OPENAI_API_BASE_URL = "http://uni-api.localhost/v1";

      ENABLE_LOGIN_FORM = "False";
      ENABLE_SIGNUP = "False";
      ENABLE_OAUTH_SIGNUP = "True";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
      OAUTH_CLIENT_ID = "open-webui";
      OAUTH_SCOPES = "openid profile email groups";
      ENABLE_OAUTH_ROLE_MANAGEMENT = "True";
      OAUTH_ROLES_CLAIM = "groups";
      OPENID_PROVIDER_URL = "https://login.lantian.pub/.well-known/openid-configuration";

      RAG_EMBEDDING_ENGINE = "ollama";
      PDF_EXTRACT_IMAGES = "true";
      RAG_EMBEDDING_MODEL = "mxbai-embed-large:latest";

      ENABLE_IMAGE_GENERATION = "true";
      IMAGE_GENERATION_ENGINE = "automatic1111";
      AUTOMATIC1111_BASE_URL = "https://stable-diffusion.xuyh0120.win";
      IMAGE_SIZE = "512x512";
      IMAGE_STEPS = "20";

      ENABLE_RAG_WEB_SEARCH = "true";
      ENABLE_SEARCH_QUERY = "true";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "https://searx.xuyh0120.win/search?q=<query>";
      RAG_WEB_SEARCH_RESULT_COUNT = "5";
      RAG_WEB_SEARCH_CONCURRENT_REQUESTS = "1";
    };
  };

  systemd.services.open-webui.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "open-webui";
    Group = "open-webui";
  };
  users.users.open-webui = {
    group = "open-webui";
    isSystemUser = true;
  };
  users.groups.open-webui = { };

  lantian.nginxVhosts = {
    "open-webui.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenWebUI}";
        proxyWebsockets = true;
      };

      sslCertificate = "xuyh0120.win_ecc";
      noIndex.enable = true;

      extraConfig = ''
        client_max_body_size 0;
      '';
    };
  };
}
