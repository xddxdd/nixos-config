{ pkgs, config, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };
in
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings.mysqld = {
      bind-address = LT.this.ltnet.IPv4;
      innodb_autoinc_lock_mode = 2;
      innodb_file_per_table = 1;
      innodb_flush_method = "fsync";
      innodb_read_only_compressed = 0;
      performance_schema = false;
    };
  };

  services.automysqlbackup = {
    enable = true;
    config = {
      db_exclude = [ "information_schema" "performance_schema" "sys" "test" ];
    };
  };

  services.nginx.virtualHosts."pma.lantian.pub" = pkgs.lib.mkIf config.lantian.enable-php {
    listen = LT.nginx.listenHTTPS;
    root = "/var/www/pma.lantian.pub";
    locations = LT.nginx.addCommonLocationConf {
      "/" = {
        index = "index.php";
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
