{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  root = "/var/www/ltn.pw";

  yourlsAddons = {
    "user/plugins/404-if-not-found" = LT.sources.yourls-404-if-not-found.src;
    "user/plugins/Always-302" = LT.sources.yourls-always-302.src;
    "user/plugins/dont-log-crawlers" = LT.sources.yourls-dont-log-crawlers.src;
    "user/plugins/sleeky-backend" = LT.sources.yourls-sleeky.src + "/sleeky-backend";
    "user/plugins/yourls-dont-track-admins" = LT.sources.yourls-dont-track-admins.src;
    "user/plugins/yourls-login-timeout" = LT.sources.yourls-login-timeout.src;
  };

  yourlsAddonsInstall = builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "cp -r ${v} ${k}") yourlsAddons);

  yourlsPackage = pkgs.stdenvNoCC.mkDerivation {
    inherit (LT.sources.yourls) pname version src;

    buildPhase = ''
      ln -sf ${root}/user/config.php user/config.php
      ${yourlsAddonsInstall}
    '';

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
in {
  imports = [./mysql.nix];

  services.phpfpm.pools.yourls = {
    phpPackage = pkgs.php.withExtensions ({
      enabled,
      all,
    }:
      with all;
        enabled
        ++ [
          bcmath
          curl
          dom
          filter
          gmp
          iconv
          mbstring
          openssl
          pdo
          pdo_mysql
          posix
          zlib
        ]);
    user = "yourls";
    group = "yourls";
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
    "ltn.pw" = {
      listen = LT.nginx.listenHTTPS;
      root = "${yourlsPackage}";
      locations =
        LT.nginx.addCommonLocationConf
        {phpfpmSocket = config.services.phpfpm.pools.yourls.socket;}
        {
          "= /".return = "302 https://lantian.pub";
          "/" = {
            index = "index.php";
            tryFiles = "$uri $uri/ /yourls-loader.php$is_args$args";
          };
        };
      extraConfig =
        LT.nginx.makeSSL "ltn.pw_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
  };

  services.mysql = {
    enable = true;
    ensureDatabases = ["yourls"];
    ensureUsers = [
      {
        name = "yourls";
        ensurePermissions = {
          "yourls.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  users.users.yourls = {
    group = "yourls";
    isSystemUser = true;
  };

  users.groups.yourls = {};
}
