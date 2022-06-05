{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [ ./postgresql.nix ];

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "127.0.0.1:${LT.portStr.Miniflux}";
      CREATE_ADMIN = lib.mkForce "0";
      AUTH_PROXY_HEADER = "X-User";
      AUTH_PROXY_USER_CREATION = "1";
    };
    adminCredentialsFile = ../../README.md; # Dummy file
  };

  services.nginx.virtualHosts = {
    "feeds.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { noindex = true; } {
        "/".extraConfig = LT.nginx.locationBasicAuthConf + ''
          proxy_pass http://127.0.0.1:${LT.portStr.Miniflux};
        '' + LT.nginx.locationProxyConf;
      };
      extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true;
    };
  };

  systemd.services.miniflux.serviceConfig.EnvironmentFile = lib.mkForce null;
}
