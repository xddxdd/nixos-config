{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
  };

  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
  };

  systemd.services.postgresql.serviceConfig = LT.serviceHarden;

  services.phpfpm.pools.pga = {
    phpPackage = pkgs.php.withExtensions ({ enabled, all }: with all; enabled ++ [
      pdo
      pdo_pgsql
      pgsql
    ]);
    inherit (config.services.nginx) user;
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

  age.secrets.phppgadmin-conf = {
    file = pkgs.secrets + "/phppgadmin-conf.age";
    owner = "nginx";
    group = "nginx";
  };
  systemd.tmpfiles.rules = [
    "L+ /etc/phppgadmin/config.inc.php - - - - ${config.age.secrets.phppgadmin-conf.path}"
  ];
  services.nginx.virtualHosts = {
    "pga.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      root = "${pkgs.phppgadmin}";
      locations = LT.nginx.addCommonLocationConf
        { phpfpmSocket = config.services.phpfpm.pools.pga.socket; }
        {
          "/".index = "index.php";
        };
      extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "pga.localhost" = {
      listen = LT.nginx.listenHTTP;
      root = "${pkgs.phppgadmin}";
      locations = LT.nginx.addCommonLocationConf
        { phpfpmSocket = config.services.phpfpm.pools.pga.socket; }
        {
          "/".index = "index.php";
        };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };
  };
}
