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
    };
  };

  services.nginx.virtualHosts."netbox.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
      "/" = {
        proxyPass = "http://${config.services.netbox.listenAddress}:${LT.portStr.Netbox}";
        extraConfig = LT.nginx.locationProxyConf;
      };
      "/static/".alias = config.services.netbox.settings.STATIC_ROOT + "/";
    };
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  users.groups.netbox.members = ["nginx"];
}
