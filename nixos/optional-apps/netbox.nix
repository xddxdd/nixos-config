{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [
    ./postgresql.nix
  ];

  age.secrets.netbox-secret = {
    file = inputs.secrets + "/netbox-secret.age";
    owner = "netbox";
    group = "netbox";
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox_3_6;
    listenAddress = "[::1]";
    port = LT.port.Netbox;
    secretKeyFile = config.age.secrets.netbox-secret.path;
    settings = {
      CSRF_TRUSTED_ORIGINS = ["https://netbox.xuyh0120.win"];
      REMOTE_AUTH_AUTO_CREATE_GROUPS = true;
      REMOTE_AUTH_AUTO_CREATE_USER = true;
      REMOTE_AUTH_BACKEND = "netbox.authentication.RemoteUserBackend";
      REMOTE_AUTH_ENABLED = true;
      REMOTE_AUTH_GROUP_HEADER = "HTTP_X_GROUPS";
      REMOTE_AUTH_GROUP_SEPARATOR = ",";
      REMOTE_AUTH_GROUP_SYNC_ENABLED = true;
      REMOTE_AUTH_HEADER = "HTTP_X_USER";
      REMOTE_AUTH_SUPERUSERS = ["lantian"];
      REMOTE_AUTH_USER_EMAIL = "HTTP_X_EMAIL";
    };
  };

  services.nginx.virtualHosts."netbox.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
      "/".extraConfig =
        LT.nginx.locationOauthConf
        + ''
          proxy_pass http://${config.services.netbox.listenAddress}:${LT.portStr.Netbox};
        ''
        + LT.nginx.locationProxyConf;
      "/static/".alias = config.services.netbox.settings.STATIC_ROOT + "/";
    };
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  users.groups.netbox.members = ["nginx"];
}
