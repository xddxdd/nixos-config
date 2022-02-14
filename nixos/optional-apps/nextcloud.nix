{ pkgs, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  imports = [ ./mysql.nix ];

  age.secrets.nextcloud-pw = {
    file = ../../secrets/nextcloud-pw.age;
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud23;
    autoUpdateApps.enable = true;
    config = {
      adminpassFile = config.age.secrets.nextcloud-pw.path;
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
    listen = pkgs.lib.mkForce LT.nginx.listenHTTPS;
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.noIndex;
  };
}
