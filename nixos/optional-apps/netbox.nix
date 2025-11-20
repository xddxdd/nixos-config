{
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  age.secrets.netbox-oauth-secret = {
    file = inputs.secrets + "/dex/netbox-secret.age";
    owner = "netbox";
    group = "netbox";
  };
  age.secrets.netbox-secret = {
    file = inputs.secrets + "/netbox-secret.age";
    owner = "netbox";
    group = "netbox";
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    plugins = python3Packages: [
      python3Packages.social-auth-core
    ];
    unixSocket = "/run/netbox/netbox.sock";
    secretKeyFile = config.age.secrets.netbox-secret.path;
    settings = {
      CSRF_TRUSTED_ORIGINS = [ "https://netbox.xuyh0120.win" ];
      REMOTE_AUTH_AUTO_CREATE_GROUPS = true;
      REMOTE_AUTH_AUTO_CREATE_USER = true;
      REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth";
      REMOTE_AUTH_ENABLED = true;
      REMOTE_AUTH_GROUP_HEADER = "HTTP_X_GROUPS";
      REMOTE_AUTH_GROUP_SEPARATOR = ",";
      REMOTE_AUTH_GROUP_SYNC_ENABLED = true;
      REMOTE_AUTH_HEADER = "HTTP_X_USER";
      REMOTE_AUTH_SUPERUSER_GROUPS = [ "admin" ];
      REMOTE_AUTH_USER_EMAIL = "HTTP_X_EMAIL";

      LOGIN_FORM_HIDDEN = "true";

      SOCIAL_AUTH_OIDC_OIDC_ENDPOINT = "https://login.lantian.pub";
      SOCIAL_AUTH_OIDC_KEY = "netbox";
      SOCIAL_AUTH_OIDC_SCOPE = [ "groups" ];
    };
    extraConfig = ''
      with open("${config.age.secrets.netbox-oauth-secret.path}", "r") as file:
          SOCIAL_AUTH_OIDC_SECRET = file.readline()
    '';
  };

  lantian.nginxVhosts."netbox.xuyh0120.win" = {
    locations = {
      "/".proxyPass = "http://unix:/run/netbox/netbox.sock";
      "/static/".alias = config.services.netbox.settings.STATIC_ROOT + "/";
    };

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
  };

  systemd.services.netbox = {
    after = [ "redis-netbox.service" ];
    requires = [ "redis-netbox.service" ];
    serviceConfig = LT.networkToolHarden // {
      RuntimeDirectory = "netbox";
    };
  };
  systemd.services.netbox-rq = {
    after = [ "redis-netbox.service" ];
    requires = [ "redis-netbox.service" ];
    serviceConfig = LT.serviceHarden;
  };

  users.groups.netbox.members = [ "nginx" ];
}
