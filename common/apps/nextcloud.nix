{ pkgs, config, ... }:

let
  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
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
    package = pkgs.nextcloud22;
    autoUpdateApps.enable = true;
    config = {
      adminpassFile = config.age.secrets.nextcloud-pw.path;
      adminuser = "lantian";
      dbtype = "mysql";
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
    listen = pkgs.lib.mkForce nginxHelper.listen443;
    extraConfig = nginxHelper.makeSSL "lantian.pub_ecc";
  };
}
