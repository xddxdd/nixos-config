{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  options.lantian.resilio.storage = lib.mkOption {
    type = lib.types.str;
    default = "/nix/persistent/media";
    description = "Storage path for Resilio Sync";
  };

  config = {
    fileSystems."/run/rslfiles" = {
      device = config.lantian.resilio.storage;
      fsType = "fuse.bindfs";
      options = [
        "force-user=${config.systemd.services.resilio.serviceConfig.User}"
        "force-group=${config.systemd.services.resilio.serviceConfig.Group}"
        "create-for-user=root"
        "create-for-group=root"
        "chown-ignore"
        "chgrp-ignore"
        "xattr-none"
        "x-gvfs-hide"
      ];
    };

    services.resilio = {
      enable = true;
      enableWebUI = true;
      checkForUpdates = false;
      deviceName = config.networking.hostName;
      directoryRoot = lib.mkForce "/run/rslfiles";
      # Authentication is done by nginx
      httpLogin = "user";
      httpPass = "pass";
    };

    systemd.services.resilio = {
      after = ["run-rslfiles.mount"];
      requires = ["run-rslfiles.mount"];
      environment = {
        LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
      };
      serviceConfig =
        LT.serviceHarden
        // {
          User = "rslsync";
          Group = "rslsync";
          ReadWritePaths = ["/run/rslfiles"];
          StateDirectory = "resilio-sync";
          TimeoutStopSec = "10";
        };
    };

    systemd.tmpfiles.rules = [
      "d ${config.lantian.resilio.storage} 755 root root"
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
  };
}
