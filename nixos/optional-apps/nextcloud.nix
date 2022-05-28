{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  imports = [ ./mysql.nix ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud23;
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
    hostName = "cloud.lantian.pub";
    https = true;
    webfinger = true;
    occ = true;
  };

  services.redis.servers.nextcloud = {
    enable = true;
    port = 0;
    databases = 1;
    user = config.services.phpfpm.pools.nextcloud.user;
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

  services.nginx.virtualHosts."cloud.lantian.pub" = {
    listen = lib.mkForce LT.nginx.listenHTTPS;
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.noIndex;
  };
}
