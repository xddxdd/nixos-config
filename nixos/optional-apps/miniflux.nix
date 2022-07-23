{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [ ./postgresql.nix ];

  age.secrets.miniflux-konnect-secret = {
    file = pkgs.secrets + "/konnect/miniflux-secret.age";
    owner = "miniflux";
    group = "miniflux";
  };

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "/run/miniflux/miniflux.sock";
      BASE_URL = "https://rss.xuyh0120.win/";
      CLEANUP_ARCHIVE_UNREAD_DAYS = "-1";
      CLEANUP_ARCHIVE_READ_DAYS = "-1";
      HTTPS = "1";

      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "miniflux";
      OAUTH2_CLIENT_SECRET_FILE = config.age.secrets.miniflux-konnect-secret.path;
      OAUTH2_REDIRECT_URL = "https://rss.xuyh0120.win/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://login.xuyh0120.win";
      OAUTH2_USER_CREATION = "1";

      CREATE_ADMIN = lib.mkForce "0";
      PROXY_IMAGES = "all";
    };
    adminCredentialsFile = pkgs.writeText "dummy" "DUMMY=1";
  };

  services.nginx.virtualHosts."rss.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } (
      let
        proxyConfig = {
          proxyPass = "http://unix:/run/miniflux/miniflux.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      in
      {
        "/" = proxyConfig;
        # Bypass oauth-proxy for URL conflicts
        "/oauth2/" = proxyConfig;
        "/oauth2/auth" = proxyConfig;
      }
    );
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  systemd.services.miniflux.serviceConfig = {
    DynamicUser = lib.mkForce false;
    RuntimeDirectoryMode = lib.mkForce "0755";
    UMask = lib.mkForce "0022";
    User = "miniflux";
    Group = "miniflux";
  };

  users.users.miniflux = {
    group = "miniflux";
    isSystemUser = true;
  };
  users.groups.miniflux = { };
}
