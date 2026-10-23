{
  pkgs,
  LT,
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
    serviceConfig = LT.networkToolHarden // {
      RuntimeDirectory = "netbox";
      BindReadOnlyPaths = [ "/run/postgresql" ];
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
    serviceConfig = LT.serviceHarden // {
      BindReadOnlyPaths = [ "/run/postgresql" ];
    };
  };
  lantian.harden.netbox = true;
  lantian.harden.netbox-rq = true;

  users.groups.netbox.members = [ "nginx" ];
}
