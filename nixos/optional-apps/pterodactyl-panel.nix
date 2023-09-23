{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  root = "/var/www/pterodactyl.xuyh0120.win";
  pterodactyl-artisan = pkgs.writeShellScriptBin "pterodactyl-artisan" ''
    cd ${root}
    sudo -u pterodactyl ${pkgs.php}/bin/php artisan "$@"
  '';
  pterodactyl-composer = pkgs.writeShellScriptBin "pterodactyl-composer" ''
    cd ${root}
    sudo -u pterodactyl ${pkgs.phpPackages.composer}/bin/composer "$@"
  '';
in {
  imports = [
    ./mysql.nix
  ];

  environment.systemPackages = [
    pterodactyl-artisan
    pterodactyl-composer
  ];

  services.mysql = {
    ensureDatabases = ["pterodactyl"];
    ensureUsers = [
      {
        name = "pterodactyl";
        ensurePermissions = {
          "pterodactyl.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.phpfpm.pools.pterodactyl = {
    phpPackage = pkgs.php.withExtensions ({
      enabled,
      all,
    }:
      with all;
        enabled
        ++ [
          bcmath
          curl
          gd
          mbstring
          mysqli
          mysqlnd
          openssl
          pdo
          pdo_mysql
          tokenizer
          xml
          zip
        ]);
    user = "pterodactyl";
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

  services.redis.servers.pterodactyl = {
    enable = true;
    port = LT.port.Pterodactyl.Redis;
    databases = 1;
    user = "pterodactyl";
  };

  services.nginx.virtualHosts ."pterodactyl.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    root = "${root}/public";
    locations =
      LT.nginx.addCommonLocationConf
      {phpfpmSocket = config.services.phpfpm.pools.pterodactyl.socket;}
      {
        "/" = {
          tryFiles = "$uri $uri/ /index.php?$query_string";
          index = "index.php";
        };
      };
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true
      + LT.nginx.servePrivate null;
  };

  systemd.tmpfiles.rules = [
    "d ${root} 755 pterodactyl pterodactyl"
  ];

  users.users.pterodactyl = {
    group = "pterodactyl";
    isSystemUser = true;
  };
  users.groups.pterodactyl = {};
}
