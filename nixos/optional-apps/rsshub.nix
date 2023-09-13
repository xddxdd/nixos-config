{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  virtualisation.oci-containers.containers.rsshub = {
    extraOptions = ["--pull" "always"];
    image = "diygod/rsshub:chromium-bundled";
    environment = {
      CACHE_CONTENT_EXPIRE = "600";
    };
    ports = [
      "127.0.0.1:${LT.portStr.RSSHub}:1200"
    ];
  };

  services.nginx.virtualHosts."rsshub.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.RSSHub}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true
      + LT.nginx.servePrivate null;
  };
}
