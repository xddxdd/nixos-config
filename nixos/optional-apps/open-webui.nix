{
  LT,
  config,
  inputs,
  pkgs,
  ...
}:
{
  age.secrets.open-webui-env.file = inputs.secrets + "/open-webui-env.age";

  services.open-webui = {
    enable = true;
    package = inputs.nixpkgs-stable.legacyPackages."${pkgs.system}".open-webui;
    port = LT.port.OpenWebUI;
    environmentFile = config.age.secrets.open-webui-env.path;
    environment = {
      ENV = "prod";
      OLLAMA_API_BASE_URL = "https://ollama.lt-home-vm.xuyh0120.win";
      WEBUI_URL = "https://open-webui.$xuyh0120.win";
      ENABLE_LOGIN_FORM = "False";
      ENABLE_SIGNUP = "False";
      ENABLE_OAUTH_SIGNUP = "True";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
      OAUTH_CLIENT_ID = "open-webui";
      OAUTH_SCOPES = "openid profile email groups";
      ENABLE_OAUTH_ROLE_MANAGEMENT = "True";
      OAUTH_ROLES_CLAIM = "groups";
      OPENID_PROVIDER_URL = "https://login.lantian.pub/.well-known/openid-configuration";
    };
  };

  lantian.nginxVhosts = {
    "open-webui.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenWebUI}";
      };

      sslCertificate = "xuyh0120.win_ecc";
      noIndex.enable = true;
    };
  };
}
