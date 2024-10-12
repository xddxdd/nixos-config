{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  age.secrets.miniflux-oauth-secret = {
    file = inputs.secrets + "/miniflux-oauth-secret.age";
    owner = "miniflux";
    group = "miniflux";
  };

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "/run/miniflux/miniflux.sock";
      BASE_URL = "https://rss.xuyh0120.win/";
      POLLING_PARSING_ERROR_LIMIT = "0";
      CLEANUP_ARCHIVE_UNREAD_DAYS = "-1";
      CLEANUP_ARCHIVE_READ_DAYS = "-1";
      HTTPS = "1";

      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "miniflux";
      OAUTH2_CLIENT_SECRET_FILE = config.age.secrets.miniflux-oauth-secret.path;
      OAUTH2_REDIRECT_URL = "https://rss.xuyh0120.win/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://login.lantian.pub";
      OAUTH2_USER_CREATION = "1";

      CREATE_ADMIN = lib.mkForce "0";
      PROXY_IMAGES = "all";
    };
    adminCredentialsFile = pkgs.writeText "dummy" "DUMMY=1";
  };

  lantian.nginxVhosts."rss.xuyh0120.win" = {
    locations =
      let
        proxyConfig = {
          proxyPass = "http://unix:/run/miniflux/miniflux.sock";
        };
      in
      {
        "/" = proxyConfig;
        # Bypass oauth-proxy for URL conflicts
        "/oauth2/" = proxyConfig;
        "/oauth2/auth" = proxyConfig;
      };

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
  };

  systemd.services.miniflux.serviceConfig = {
    DynamicUser = lib.mkForce false;
    RuntimeDirectoryMode = lib.mkForce "0770";
    UMask = lib.mkForce "0007";
    User = "miniflux";
    Group = "miniflux";
  };

  users.users.miniflux = {
    group = "miniflux";
    isSystemUser = true;
  };
  users.groups.miniflux.members = [ "nginx" ];
}
