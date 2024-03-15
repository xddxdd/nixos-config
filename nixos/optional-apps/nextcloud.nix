{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  imports = [ ./mysql.nix ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    autoUpdateApps.enable = true;
    caching = {
      apcu = true;
      redis = true;
    };
    config = {
      adminpassFile = config.age.secrets.default-pw.path;
      adminuser = "lantian";
      dbtype = "mysql";
    };
    hostName = "cloud.xuyh0120.win";
    https = true;
    webfinger = true;
    occ = true;

    settings = {
      default_phone_region = "CN";
      overwriteprotocol = "https";
      "integrity.check.disabled" = true;
    };
  };

  services.redis.servers.nextcloud = {
    enable = true;
    port = 0;
    databases = 1;
    inherit (config.services.phpfpm.pools.nextcloud) user;
  };

  systemd.services.nextcloud-setup.unitConfig = {
    After = "mysql.service";
  };

  services.mysql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions = {
          "nextcloud.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  lantian.nginxVhosts."cloud.xuyh0120.win" = {
    # Nextcloud sends "X-Robots-Tag: none" itself, no need for noIndex
    sslCertificate = "xuyh0120.win_ecc";
    enableCommonLocationOptions = false;
    enableCommonVhostOptions = false;
  };
}
