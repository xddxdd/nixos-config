{
  LT,
  config,
  pkgs,
  lib,
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

  commit = builtins.head (lib.splitString "-" LT.sources.iyuuplus.version);

  iyuuTree =
    pkgs.runCommand "iyuuplus-tree-${lib.substring 0 7 commit}"
      {
        nativeBuildInputs = [ pkgs.gnused ];
      }
      ''
        mkdir -p $out
        cp -r ${LT.sources.iyuuplus.src}/* $out/
        chmod -R u+w $out

        # mutable state is not part of the source tree
        rm -rf $out/runtime $out/vendor $out/.env $out/.git

        # Main webman server listens on the LTnet-fronted local port
        sed -E -i "s#'listen' => .*#'listen' => 'http://127.0.0.1:${LT.portStr.IyuuPlus}',#g" \
          $out/config/server.php

        # WorkerMan push websocket/api and the cron frame listener default to
        # 0.0.0.0; nginx fronts the websocket and both are LTnet-local
        sed -i 's#0\.0\.0\.0#127.0.0.1#g' \
          $out/config/plugin/webman/push/app.php \
          $out/plugin/cron/config/crontab.php
        # MySQL credentials resolve natively from the .env environment at
        # runtime (upstream config/database.php reads getenv directly)
      '';

  # Store closure of the app: every static file from the patched tree plus
  # symlinks that route the mutable parts to the real paths under /var/lib,
  # so the unit can run directly from the store while runtime/, vendor/ and
  # .env stay writable on disk (linkFarm-style, cf. the wordpress module).
  iyuuplusClosure =
    pkgs.runCommand "iyuuplus-${lib.substring 0 7 commit}-closure"
      {
        pname = "iyuuplus";
        version = LT.sources.iyuuplus.version;
        passthru.tree = iyuuTree;
        meta.mainProgram = "start.php";
      }
      ''
        mkdir -p $out
        cp -r ${iyuuTree}/* $out/
        # mutable state is not part of the store; route it to real paths
        rm -rf $out/runtime $out/vendor $out/.env $out/.git
        ln -s /var/lib/iyuu/runtime $out/runtime
        ln -s /var/lib/iyuu/vendor $out/vendor
        ln -s /var/lib/iyuu/.env $out/.env
      '';
in
{
  imports = [ ./mysql.nix ];

  sops.secrets.iyuu-token = {
    sopsFile = LT.secret "iyuu.yaml";
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

    preStart = ''
      # Provision the mutable state the closure's symlinks point at; this is
      # what the app will actually write to (runtime/, vendor/, .env)
      mkdir -p /var/lib/iyuu/runtime
      if [ ! -e /var/lib/iyuu/.env ]; then
        install -m644 -o iyuu -g iyuu ${config.sops.templates.iyuu-env.path} /var/lib/iyuu/.env
      fi

      # One-time cleanup of the previous git-managed deployment; the app tree
      # now lives entirely in the store closure
      ${pkgs.coreutils}/bin/rm -rf /var/lib/iyuu/.git

      # composer dependencies are mutable state, provisioned once and reused
      # by later generations via the closure's vendor symlink
      if [ ! -e /var/lib/iyuu/vendor/autoload.php ]; then
        ${pkgs.php83Packages.composer}/bin/composer install \
          --no-dev --no-interaction -d /var/lib/iyuu
      fi
    '';

    serviceConfig = {
      ExecStart = "${lib.getExe' php-iyuu "php"} ${iyuuplusClosure}/start.php start";
      StateDirectory = "iyuu";
      WorkingDirectory = "${iyuuplusClosure}";
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
