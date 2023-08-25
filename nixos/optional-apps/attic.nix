{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  age.secrets.attic-credentials = {
    file = inputs.secrets + "/attic-credentials.age";
    owner = "atticd";
    group = "atticd";
  };

  services.atticd = {
    enable = true;
    package = pkgs.attic-server;
    credentialsFile = config.age.secrets.attic-credentials.path;
    settings = {
      listen = "[::1]:${LT.portStr.Attic}";
      database.heartbeat = true;
      require-proof-of-possession = false;
      storage = {
        type = "s3";
        region = "phoenix";
        bucket = "lantian-attic";
        endpoint = "https://storage.telnyx.com";
      };
      # Use btrfs deduplication
      chunking = {
        nar-size-threshold = 0;
        min-size = 16384;
        avg-size = 65536;
        max-size = 262144;
      };
      # Use btrfs compression
      compression = {
        type = "zstd";
        level = 9;
      };
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "1 month";
      };
    };
  };

  systemd.services.atticd = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
    };
  };

  users.users.atticd = {
    group = "atticd";
    isSystemUser = true;
  };
  users.groups.atticd = {};

  services.nginx.virtualHosts = {
    "attic.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://[::1]:${LT.portStr.Attic}";
          extraConfig =
            LT.nginx.locationProxyConf
            + LT.nginx.locationNoTimeoutConf;
        };
      };
      extraConfig =
        LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "attic.${config.networking.hostName}.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://[::1]:${LT.portStr.Attic}";
          extraConfig =
            LT.nginx.locationProxyConf
            + LT.nginx.locationNoTimeoutConf;
        };
      };
      extraConfig =
        LT.nginx.makeSSL "${config.networking.hostName}.xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
  };
}
