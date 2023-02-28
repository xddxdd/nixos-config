{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
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

  systemd.services.resilio = {
    environment = {
      LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        User = lib.mkForce "root";
        Group = lib.mkForce "root";
        ReadWritePaths = [config.services.resilio.directoryRoot];
        StateDirectory = "resilio-sync";
        TimeoutStopSec = "10";

        # Disable logging
        StandardOutput = "null";
        StandardError = "null";
      };
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.resilio.directoryRoot} 775 root root"
  ];

  services.nginx.virtualHosts = {
    "resilio.${config.networking.hostName}.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/".extraConfig =
          LT.nginx.locationOauthConf
          + ''
            proxy_pass http://unix:/run/rslsync/rslsync.sock;
            proxy_set_header Authorization "Basic dXNlcjpwYXNz";
          ''
          + LT.nginx.locationProxyConf;
      };
      extraConfig =
        LT.nginx.makeSSL "${config.networking.hostName}.xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "resilio.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf {} {
        "/".extraConfig =
          ''
            proxy_pass http://unix:/run/rslsync/rslsync.sock;
            proxy_set_header Authorization "Basic dXNlcjpwYXNz";
          ''
          + LT.nginx.locationProxyConf;
      };
      extraConfig =
        LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };
  };
}
