{ pkgs, config, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;

  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
in
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    bind = thisHost.ltnet.IPv4;
    settings.mysqld = {
      innodb_autoinc_lock_mode = 2;
      innodb_file_per_table = 1;
      innodb_read_only_compressed = 0;
      performance_schema = false;
    };
    extraOptions = ''
      skip-host-cache
      skip-name-resolve
    '';
  };

  services.nginx.virtualHosts."pma.lantian.pub" = pkgs.lib.mkIf config.lantian.enable-php {
    listen = nginxHelper.listen443;
    root = "/var/www/pma.lantian.pub";
    locations = nginxHelper.addCommonLocationConf {
      "/" = {
        index = "index.php";
      };
    };
    extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true
      + nginxHelper.noIndex;
  };
}
