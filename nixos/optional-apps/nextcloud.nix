{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [ ./mysql.nix ];

  age.secrets.nextcloud-s3-secret = {
    file = pkgs.secrets + "/nextcloud-s3-secret.age";
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud25;
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

      objectstore.s3 = {
        enable = true;
        key = "nextcloud";
        region = "us-east-1";
        bucket = "nextcloud";
        autocreate = false;
        hostname = "s3.xuyh0120.win";
        secretFile = config.age.secrets.nextcloud-s3-secret.path;
        usePathStyle = true;
      };
    };
    hostName = "cloud.xuyh0120.win";
    https = true;
    webfinger = true;
    occ = true;
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
    ensureUsers = [{
      name = "nextcloud";
      ensurePermissions = {
        "nextcloud.*" = "ALL PRIVILEGES";
      };
    }];
  };

  services.nginx.virtualHosts."cloud.xuyh0120.win" = {
    listen = lib.mkForce LT.nginx.listenHTTPS;
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.noIndex false;
  };
}
