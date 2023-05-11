{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  rslConfig = {
    device_name = config.networking.hostName;
    storage_path = "/var/lib/resilio-sync/";
    listening_port = 0;
    use_gui = false;
    check_for_updates = false;
    use_upnp = true;
    download_limit = 0;
    upload_limit = 0;
    lan_encrypt_data = true;
    directory_root = "/run/rslfiles";

    # Power user preferences: https://help.resilio.com/hc/en-us/articles/207371636-Power-user-preferences
    log_size = 4;
    log_ttl = 1;
    disk_low_priority = true;
    disk_worker_per_job = true;
    show_service_disk_thread = true;
    parallel_indexing = true;

    # Inotify doesn't work with bindfs
    enable_file_system_notifications = false;
    folder_rescan_interval = 60;

    # Do not change! Hardcoded value for ip2unix and nginx reverse proxy
    webui = {
      listen = "[::1]:9000";
      login = "user";
      password = "pass";
    };
  };
in {
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

    users.users.rslsync = {
      description = "Resilio Sync Service user";
      home = rslConfig.storage_path;
      createHome = true;
      uid = config.ids.uids.rslsync;
      group = "rslsync";
    };

    users.groups.rslsync = {};

    systemd.services.resilio = {
      description = "Resilio Sync Service";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "run-rslfiles.mount"];
      requires = ["network.target" "run-rslfiles.mount"];

      script = let
        cfgFile = pkgs.writeText "config.json" (builtins.toJSON rslConfig);
      in ''
        exec ${pkgs.ip2unix}/bin/ip2unix -r in,tcp,port=9000,path=/run/rslsync/rslsync.sock \
          ${pkgs.resilio-sync}/bin/rslsync --nodaemon --config ${cfgFile}
      '';

      serviceConfig =
        LT.serviceHarden
        // {
          Restart = "on-abort";
          UMask = "0002";
          RuntimeDirectory = "rslsync";
          ExecStartPost = pkgs.writeShellScript "rslsync-post" ''
            while [ ! -S /run/rslsync/rslsync.sock ]; do sleep 1; done
            chmod 777 /run/rslsync/rslsync.sock
          '';

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
