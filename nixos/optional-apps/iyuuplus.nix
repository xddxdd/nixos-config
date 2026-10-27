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

  iyuuDbConfigPhp = pkgs.writeText "iyuuplus-database.php" ''
    <?php
    return [
        'default' => 'mysql',
        'connections' => [
            'mysql' => [
                'driver' => 'mysql',
                'host' => getenv('DB_HOST'),
                'port' => getenv('DB_PORT'),
                'database' => getenv('DB_DATABASE'),
                'username' => getenv('DB_USERNAME'),
                'password' => getenv('DB_PASSWORD'),
                'charset' => 'utf8mb4',
                'collation' => 'utf8mb4_general_ci',
                "prefix" => "",
                'strict' => true,
                'engine' => null,
            ],
        ],
    ];
  '';
in
{
  imports = [ ./mysql.nix ];

  sops.secrets.iyuu-token = {
    sopsFile = inputs.secrets + "/iyuu.yaml";
    owner = "iyuu";
    group = "iyuu";
  };
  sops.templates.iyuu-env = {
    content = ''
      APP_DEBUG=false
      APP_ENV=prod

      DB_CONNECTION=mysql
      DB_HOST=localhost
      DB_PORT=3306
      DB_DATABASE=iyuu
      DB_USERNAME=iyuu
      DB_PASSWORD=iyuu

      CONFIG_NOT_MYSQL=0
      SERVER_LISTEN_PORT=13878
      IYUU_LISTEN_IPV6=0
      IYUU_TOKEN=${config.sops.placeholder.iyuu-token}
      IYUU_APPID={{IYUU_APPID}}
      IYUU_SECRET={{IYUU_SECRET}}
      CLOUD_ACCESS_TOKEN=
      CLOUD_SN=
      CLOUD_DEBUG=0
    '';
    owner = "iyuu";
    group = "iyuu";
  };

  systemd.services.iyuuplus = {
    wantedBy = [ "multi-user.target" ];
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];

    path = with pkgs; [ gitMinimal ];

    preStart = ''
      # Systemd/tmpfiles may pre-populate the state dir (runtime/); update
      # in place instead of cloning into a non-empty target
      if [ -e .git ]; then
        git fetch --all
        git reset --hard origin/master
      else
        git init .
        git remote add origin https://github.com/ledccn/iyuuplus-dev.git
        git fetch origin
        git reset --hard origin/master
      fi
      # The install-wizard gate keys off this snapshot file, which is untracked
      # and was lost with the old state dir; runtime DB access resolves from
      # .env, so regenerate the snapshot with the same values
      install -m644 ${iyuuDbConfigPhp} plugin/admin/config/database.php
      sed -E -i "s#'listen'.*#'listen' => 'http://127.0.0.1:${LT.portStr.IyuuPlus}',#g" config/server.php
      install -Dm644 ${config.sops.templates.iyuu-env.path} .env
    '';

    serviceConfig = {
      ExecStart = "${lib.getExe' php-iyuu "php"} /var/lib/iyuu/start.php start";
      StateDirectory = "iyuu";
      WorkingDirectory = "/var/lib/iyuu";
      User = "iyuu";
      Group = "iyuu";
      MemoryDenyWriteExecute = lib.mkForce false;

      Restart = "always";
      RestartSec = "5";
    };
  };

  lantian.harden.iyuuplus = {
    enable = true;
    enableConfinement = false;
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

  lantian.localVhosts.iyuu = {
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
  };
}
