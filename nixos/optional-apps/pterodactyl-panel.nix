{
  pkgs,
  LT,
  config,
  ...
}:
let
  root = "/var/www/pterodactyl.xuyh0120.win";
  pterodactyl-artisan = pkgs.writeShellScriptBin "pterodactyl-artisan" ''
    cd ${root}
    sudo -u pterodactyl ${pkgs.php}/bin/php artisan "$@"
  '';
  pterodactyl-composer = pkgs.writeShellScriptBin "pterodactyl-composer" ''
    cd ${root}
    sudo -u pterodactyl ${pkgs.phpPackages.composer}/bin/composer "$@"
  '';
in
{
  imports = [ ./mysql.nix ];

  environment.systemPackages = [
    pterodactyl-artisan
    pterodactyl-composer
  ];

  services.mysql = {
    ensureDatabases = [ "pterodactyl" ];
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
    phpPackage = pkgs.php.withExtensions (
      { enabled, all }:
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
      ]
    );
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

  lantian.nginxVhosts."pterodactyl.xuyh0120.win" = {
    root = "${root}/public";
    locations = {
      "/" = {
        tryFiles = "$uri $uri/ /index.php?$query_string";
        index = "index.php";
      };
    };

    phpfpmSocket = config.services.phpfpm.pools.pterodactyl.socket;
    sslCertificate = "xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };

  systemd.tmpfiles.rules = [ "d ${root} 755 pterodactyl pterodactyl" ];

  systemd.services.pterodactyl-cron = {
    description = "Pterodactyl Cron Job";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.php}/bin/php artisan schedule:run";
      User = "pterodactyl";
      Group = "pterodactyl";
      WorkingDirectory = root;

      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallErrorNumber = "EPERM";
    };
  };

  systemd.timers.pterodactyl-cron = {
    wantedBy = [ "timers.target" ];
    partOf = [ "pterodactyl-cron.service" ];
    timerConfig = {
      OnCalendar = "*:*";
      Unit = "pterodactyl-cron.service";
    };
  };

  systemd.services.pterodactyl-queue-worker = {
    description = "Pterodactyl Queue Worker";
    wantedBy = [ "multi-user.target" ];
    after = [
      "redis-pterodactyl.service"
      "mysql.service"
    ];
    requires = [
      "redis-pterodactyl.service"
      "mysql.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.php}/bin/php artisan queue:work --queue=high,standard,low --sleep=3 --tries=3";
      User = "pterodactyl";
      Group = "pterodactyl";
      WorkingDirectory = root;

      Restart = "always";
      RestartSec = "5";

      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallErrorNumber = "EPERM";
    };
  };

  users.users.pterodactyl = {
    group = "pterodactyl";
    isSystemUser = true;
  };
  users.groups.pterodactyl = { };
}
