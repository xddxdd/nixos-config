{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  services.calibre-web = {
    enable = true;
    listen = {
      ip = "127.0.0.1";
      port = LT.port.CalibreWeb;
    };
    options = {
      calibreLibrary = "/var/lib/calibre-web/library";
      reverseProxyAuth = {
        enable = true;
        header = "X-User";
      };
    };
  };

  services.nginx.virtualHosts = {
    "books.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { noindex = true; } {
        "/".extraConfig = LT.nginx.locationBasicAuthConf + ''
          proxy_pass http://127.0.0.1:${LT.portStr.CalibreWeb};
        '' + LT.nginx.locationProxyConfHideIP;
      };
      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
  };

  systemd.services.calibre-web.serviceConfig = LT.serviceHarden // {
    ReadOnlyPaths = [
      "\"/nix/persistent/media/Calibre Library\""
    ];
  };

  # Workaround issue with space in path
  systemd.tmpfiles.rules = [
    "L+ /var/lib/calibre-web/library - - - - /nix/persistent/media/Calibre Library"
  ];
}
