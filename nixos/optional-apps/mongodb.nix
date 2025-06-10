{ pkgs, config, ... }:
{
  services.mongodb = {
    enable = true;
    bind_ip = "127.0.0.1";
    package = pkgs.mongodb-ce;
  };
  environment.systemPackages = [
    pkgs.mongosh
    pkgs.mongodb-tools
  ];
  preservation.preserveAt."/nix/persistent" = {
    directories = [
      {
        directory = config.services.mongodb.dbpath;
        user = "mongodb";
        group = "mongodb";
      }
    ];
  };

  systemd.services.mongodb = {
    after = [ "var-db-mongodb.mount" ];
    requires = [ "var-db-mongodb.mount" ];

    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  };
}
