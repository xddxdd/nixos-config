{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "/run/miniflux/miniflux.sock";
      BASE_URL = "https://rss.xuyh0120.win/";
      POLLING_PARSING_ERROR_LIMIT = "0";
      CLEANUP_ARCHIVE_UNREAD_DAYS = "-1";
      CLEANUP_ARCHIVE_READ_DAYS = "-1";
      HTTPS = "1";

      DISABLE_LOCAL_AUTH = "1";
      AUTH_PROXY_HEADER = "X-User";
      AUTH_PROXY_USER_CREATION = "1";

      FETCH_BILIBILI_WATCH_TIME = "1";
      FETCH_NEBULA_WATCH_TIME = "1";
      FETCH_ODYSEE_WATCH_TIME = "1";
      FETCH_YOUTUBE_WATCH_TIME = "1";

      CREATE_ADMIN = lib.mkForce "0";
      PROXY_IMAGES = "all";
    };
    adminCredentialsFile = pkgs.writeText "dummy" "DUMMY=1";
  };

  lantian.nginxVhosts."rss.xuyh0120.win" = {
    locations = {
      "/" = {
        enableOAuth = true;
        proxyPass = "http://unix:/run/miniflux/miniflux.sock";
      };
    };

    sslCertificate = "xuyh0120.win";
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
