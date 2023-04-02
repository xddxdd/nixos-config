{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  services.nginx.virtualHosts."private.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    root = "/var/www/private.xuyh0120.win";
    locations = LT.nginx.addCommonLocationConf {} {
      "/".index = "index.html";
    };
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true
      + LT.nginx.servePrivate;
  };
}
