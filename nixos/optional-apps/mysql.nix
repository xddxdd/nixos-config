{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
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

  # Manually add EVENT permission to automysqlbackup user!
  services.automysqlbackup = {
    enable = true;
    config = {
      db_exclude = [ "information_schema" "performance_schema" "sys" "test" ];
    };
  };

  age.secrets.phpmyadmin-conf = {
    file = pkgs.secrets + "/phpmyadmin-conf.age";
    owner = "nginx";
    group = "nginx";
  };
  systemd.tmpfiles.rules = [
    "L+ /etc/phpmyadmin/config.inc.php - - - - ${config.age.secrets.phpmyadmin-conf.path}"
  ];

  services.phpfpm.pools.pma = {
    phpPackage = pkgs.php.withExtensions ({ enabled, all }: with all; enabled ++ [
      curl
      gd
      mbstring
      mysqli
      mysqlnd
      openssl
      pdo
      pdo_mysql
      xml
      zip
    ]);
    user = config.services.nginx.user;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "ondemand";
      "pm.max_children" = "8";
      "pm.process_idle_timeout" = "10s";
      "pm.max_requests" = "1000";
      "pm.status_path" = "/php-fpm-status.php";
      "ping.path" = "/ping.php";
      "ping.response" = "pong";
      "request_terminate_timeout" = "300";
    };
  };

  services.nginx.virtualHosts = {
    "pma-${config.networking.hostName}.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      root = "${pkgs.phpmyadmin}";
      locations = LT.nginx.addCommonLocationConf
        {
          noindex = true;
          phpfpmSocket = config.services.phpfpm.pools.pma.socket;
        }
        {
          "/".index = "index.php";
        };
      extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex;
    };
    "pma.localhost" = {
      listen = LT.nginx.listenHTTP;
      root = "${pkgs.phpmyadmin}";
      locations = LT.nginx.addCommonLocationConf
        {
          noindex = true;
          phpfpmSocket = config.services.phpfpm.pools.pma.socket;
        }
        {
          "/".index = "index.php";
        };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex;
    };
  };
}
