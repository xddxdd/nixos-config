{
  LT,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  php-iyuu = pkgs.php83.withExtensions (
    { enabled, all }:
    with all;
    enabled
    ++ [
      curl
      fileinfo
      gd
      mbstring
      exif
      mysqli
      openssl
      pdo_mysql
      pdo_sqlite
      sockets
      sodium
      sqlite3
      zip
    ]
  );
in
{
  imports = [ ./mysql.nix ];

  age.secrets.iyuu-env = {
    file = inputs.secrets + "/iyuu-env.age";
    owner = "iyuu";
    group = "iyuu";
  };

  systemd.services.iyuuplus = {
    wantedBy = [ "multi-user.target" ];
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];

    path = with pkgs; [ gitMinimal ];

    preStart = ''
      if [ -e .git ]; then
        git fetch --all
        git reset --hard origin/master
      else
        git clone https://github.com/ledccn/iyuuplus-dev.git .
      fi

      sed -E -i "s#'listen'.*#'listen' => 'http://127.0.0.1:${LT.portStr.IyuuPlus}',#g" config/server.php
      install -Dm644 ${config.age.secrets.iyuu-env.path} .env
    '';

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${php-iyuu}/bin/php /var/lib/iyuu/start.php start";
      StateDirectory = "iyuu";
      WorkingDirectory = "/var/lib/iyuu";
      User = "iyuu";
      Group = "iyuu";
      MemoryDenyWriteExecute = lib.mkForce false;

      Restart = "always";
      RestartSec = "5";
    };
  };

  systemd.tmpfiles.settings = {
    iyuu = {
      "/var/lib/iyuu/runtime/crontab/observer".d = {
        mode = "755";
        user = "iyuu";
        group = "iyuu";
      };
    };
  };

  services.mysql = {
    ensureDatabases = [ "iyuu" ];
    ensureUsers = [
      {
        name = "iyuu";
        ensurePermissions = {
          "iyuu.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  users.users.iyuu = {
    group = "iyuu";
    isSystemUser = true;
  };
  users.groups.iyuu.members = [ "nginx" ];

  lantian.nginxVhosts = {
    "iyuu.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.IyuuPlus}";
          proxyWebsockets = true;
        };
        "/app/d9422b72cffad23098ad301eea0f8419" = {
          proxyPass = "http://127.0.0.1:3131";
          proxyWebsockets = true;
        };
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "iyuu.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.IyuuPlus}";
          proxyWebsockets = true;
        };
        "/app/d9422b72cffad23098ad301eea0f8419" = {
          proxyPass = "http://127.0.0.1:3131";
          proxyWebsockets = true;
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
