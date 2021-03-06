{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  services.resilio = {
    enable = true;
    enableWebUI = true;
    checkForUpdates = false;
    deviceName = config.networking.hostName;
    directoryRoot = "/nix/persistent/media";
    # Authentication is done by nginx
    httpLogin = "user";
    httpPass = "pass";
  };

  systemd.services.resilio.serviceConfig = LT.serviceHarden // {
    ReadWritePaths = [
      "/nix/persistent/media"
    ];
    StateDirectory = "resilio-sync";
    TimeoutStopSec = "10";
  };

  systemd.tmpfiles.rules = [
    "d /nix/persistent/media 775 rslsync rslsync"
  ];

  services.nginx.virtualHosts = {
    "resilio-${config.networking.hostName}.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { } {
        "/".extraConfig = LT.nginx.locationOauthConf + ''
          proxy_pass http://unix:/run/rslsync/rslsync.sock;
          proxy_set_header Authorization "Basic dXNlcjpwYXNz";
        '' + LT.nginx.locationProxyConf;
      };
      extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "resilio.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf { } {
        "/".extraConfig = ''
          proxy_pass http://unix:/run/rslsync/rslsync.sock;
          proxy_set_header Authorization "Basic dXNlcjpwYXNz";
        '' + LT.nginx.locationProxyConf;
      };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };
  };
}
