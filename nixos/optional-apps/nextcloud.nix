{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [./mysql.nix];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;
    enableBrokenCiphersForSSE = false;
    autoUpdateApps.enable = true;
    caching = {
      apcu = true;
      redis = true;
    };
    config = {
      adminpassFile = config.age.secrets.default-pw.path;
      adminuser = "lantian";
      dbtype = "mysql";
      defaultPhoneRegion = "CN";
      overwriteProtocol = "https";
    };
    hostName = "cloud.xuyh0120.win";
    https = true;
    webfinger = true;
    occ = true;

    extraOptions = {
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
    ensureDatabases = ["nextcloud"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions = {
          "nextcloud.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nginx.virtualHosts."cloud.xuyh0120.win" = {
    listen = lib.mkForce LT.nginx.listenHTTPS;
    # Nextcloud sends "X-Robots-Tag: none" itself, no need for LT.nginx.noIndex
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc";
  };
}
