{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [./postgresql.nix];

  age.secrets.attic-credentials = {
    file = inputs.secrets + "/attic-credentials.age";
    owner = "atticd";
    group = "atticd";
  };

  services.atticd = {
    enable = true;
    package = pkgs.lantianCustomized.attic-telnyx-compatible;
    credentialsFile = config.age.secrets.attic-credentials.path;
    settings = lib.mkForce {
      listen = "[::1]:${LT.portStr.Attic}";
      # Database configured with env var
      database = {};
      require-proof-of-possession = false;
      storage = {
        type = "s3";
        region = "us-central-1";
        bucket = "lantian-nix-cache";
        endpoint = "http://us-central-1.telnyxstorage.com";
      };
      # Disable chunking to use S3 direct download
      chunking = {
        nar-size-threshold = 0;
        min-size = 16384;
        avg-size = 65536;
        max-size = 262144;
      };
      compression = {
        type = "zstd";
        level = 9;
      };
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "3 month";
      };
    };
  };

  systemd.services.atticd.serviceConfig =
    LT.serviceHarden
    // {
      DynamicUser = lib.mkForce false;
      StateDirectory = lib.mkForce "";
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
