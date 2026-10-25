{
  pkgs,
  config,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    bind = "unix:/run/netbox/netbox.sock";
    settings = {
      CSRF_TRUSTED_ORIGINS = [ "https://netbox.xuyh0120.win" ];
      REMOTE_AUTH_AUTO_CREATE_GROUPS = true;
      REMOTE_AUTH_AUTO_CREATE_USER = true;
      REMOTE_AUTH_BACKEND = "netbox.authentication.RemoteUserBackend";
      REMOTE_AUTH_ENABLED = true;
      REMOTE_AUTH_GROUP_HEADER = "HTTP_X_GROUPS";
      REMOTE_AUTH_GROUP_SEPARATOR = ",";
      REMOTE_AUTH_GROUP_SYNC_ENABLED = true;
      REMOTE_AUTH_HEADER = "HTTP_X_USER";
      REMOTE_AUTH_SUPERUSER_GROUPS = [ "admin" ];
      REMOTE_AUTH_USER_EMAIL = "HTTP_X_EMAIL";
    };
  };

  lantian.nginxVhosts."netbox.xuyh0120.win" = {
    locations = {
      "/" = {
        enableOAuth = true;
        proxyPass = "http://unix:/run/netbox/netbox.sock";
      };
      # Disable OAuth for API endpoints
      "/api/".proxyPass = "http://unix:/run/netbox/netbox.sock";
      "/static/".alias = config.services.netbox.settings.STATIC_ROOT + "/";
    };

    accessibleBy = "private";
    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
  };

  systemd.services.netbox = {
    after = [
      "redis-netbox.service"
      "postgresql.target"
    ];
    requires = [
      "redis-netbox.service"
      "postgresql.target"
    ];
    serviceConfig = {
      RuntimeDirectory = "netbox";
    };
  };
  systemd.services.netbox-rq = {
    after = [
      "redis-netbox.service"
      "postgresql.target"
    ];
    requires = [
      "redis-netbox.service"
      "postgresql.target"
    ];
  };
  lantian.harden.netbox = {
    enable = "network";
    postgresql = true;
    redis = "netbox";
  };
  lantian.harden.netbox-rq = {
    enable = true;
    postgresql = true;
    redis = "netbox";
  };

  users.groups.netbox.members = [ "nginx" ];
}
