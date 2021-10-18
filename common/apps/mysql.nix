{ pkgs, config, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    bind = "${thisHost.ltnet.IPv4Prefix}.1";
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
}
