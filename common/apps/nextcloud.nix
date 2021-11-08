{ pkgs, config, ... }:

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

  systemd.services.nextcloud-setup.enable = false;

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
}
