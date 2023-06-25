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

  age.secrets.attic-credentials.file = inputs.secrets + "/attic-credentials.age";

  services.atticd = {
    enable = true;
    package = pkgs.attic-server;
    credentialsFile = config.age.secrets.attic-credentials.path;
    settings = {
      listen = "[::1]:${LT.portStr.Attic}";
      database.url = "postgres://atticd?host=/run/postgresql&user=atticd";
      storage = {
        type = "local";
        path = lib.mkDefault "/var/lib/atticd";
      };
      # Use btrfs deduplication
      chunking = {
        nar-size-threshold = 0;
        min-size = 16384;
        avg-size = 65536;
        max-size = 262144;
      };
      # Use btrfs compression
      compression.type = "none";
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "1 month";
      };
    };
  };

  systemd.services.atticd = {
    after = ["postgresql.service"];
    requires = ["postgresql.service"];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      ReadWritePaths = [config.services.atticd.settings.storage.path];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.atticd.settings.storage.path} 755 atticd atticd"
  ];

  users.users.atticd = {
    group = "atticd";
    isSystemUser = true;
  };
  users.groups.atticd = {};

  services.postgresql = {
    ensureDatabases = ["atticd"];
    ensureUsers = [
      {
        name = "atticd";
        ensurePermissions = {
          "DATABASE \"atticd\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nginx.virtualHosts = {
    "attic.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://[::1]:${LT.portStr.Attic}";
          extraConfig = LT.nginx.locationProxyConf;
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
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.makeSSL "${config.networking.hostName}.xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
  };
}
