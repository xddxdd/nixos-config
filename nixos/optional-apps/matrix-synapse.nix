{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [./postgresql.nix];

  age.secrets.matrix-sliding-sync-env.file = inputs.secrets + "/matrix-sliding-sync-env.age";

  services.matrix-synapse = {
    enable = true;
    settings = {
      max_upload_size = "500M";
      public_baseurl = "https://matrix.lantian.pub";
      server_name = config.networking.domain;
      url_preview_enabled = true;
      media_store_path = "${config.services.matrix-synapse.dataDir}/media";
      account_threepid_delegates = {
        msisdn = "https://vector.im";
      };
      database = {
        args.user = "matrix-synapse";
        args.database = "matrix-synapse";
        name = "psycopg2";
      };
      listeners = [
        {
          port = 0;
          bind_addresses = ["/run/matrix-synapse/federation.sock"];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = ["federation"];
              compress = false;
            }
          ];
        }
        {
          port = 0;
          bind_addresses = ["/run/matrix-synapse/client.sock"];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = ["client"];
              compress = false;
            }
          ];
        }
      ];

      # Increase rate limit
      rc_admin_redaction = {
        per_second = 100;
        burst_count = 100;
      };
      rc_joins = {
        local = {
          per_second = 1;
          burst_count = 10;
        };
        remote = {
          per_second = 1;
          burst_count = 10;
        };
      };
      rc_joins_per_room = {
        per_second = 1;
        burst_count = 10;
      };
      rc_login = {
        address = {
          per_second = 1;
          burst_count = 5;
        };
        account = {
          per_second = 1;
          burst_count = 5;
        };
        failed_attempts = {
          per_second = 0.003;
          burst_count = 3;
        };
      };
      rc_message = {
        per_second = 5;
        burst_count = 10;
      };
    };

    sliding-sync = {
      enable = true;
      createDatabase = true;
      environmentFile = config.age.secrets.matrix-sliding-sync-env.path;
      settings = {
        SYNCV3_BINDADDR = "127.0.0.1:0";
        SYNCV3_UNIX_SOCKET = "/run/matrix-sliding-sync/listen.socket";
        SYNCV3_SERVER = "https://matrix.lantian.pub";
      };
    };
  };

  systemd.services.matrix-sliding-sync.serviceConfig =
    LT.serviceHarden
    // {
      DynamicUser = lib.mkForce false;
      User = "matrix-sliding-sync";
      Group = "matrix-sliding-sync";
      RuntimeDirectory = "matrix-sliding-sync";
      StateDirectory = lib.mkForce [];
      WorkingDirectory = lib.mkForce "/run/matrix-sliding-sync";
      UMask = "007";
    };

  systemd.services.matrix-synapse = {
    environment = {
      LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        MemoryDenyWriteExecute = false;
        StateDirectory = "matrix-synapse";
        RuntimeDirectory = "matrix-synapse";
      };
  };

  services.postgresql = {
    ensureDatabases = ["matrix-synapse"];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensurePermissions = {
          "DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nginx.virtualHosts."matrix-federation.lantian.pub" = {
    listen = LT.nginx.listenHTTPSPort LT.port.Matrix.Public;
    serverAliases = [
      "matrix.lantian.pub"
      config.services.matrix-synapse.settings.server_name
    ];
    locations = LT.nginx.addCommonLocationConf {} {
      "/" = {
        proxyPass = "http://unix:/run/matrix-synapse/federation.sock";
        extraConfig =
          LT.nginx.locationProxyConf
          + LT.nginx.locationNoTimeoutConf
          + ''
            proxy_http_version 1.1;
          '';
      };
    };
    extraConfig =
      LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  services.nginx.virtualHosts."matrix-client.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    serverAliases = ["matrix.lantian.pub"];
    locations = LT.nginx.addCommonLocationConf {} {
      "/" = {
        proxyPass = "http://unix:/run/matrix-synapse/client.sock";
        extraConfig = LT.nginx.locationProxyConf;
      };

      # Sliding sync proxy
      "~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
        proxyPass = "http://unix:/run/matrix-sliding-sync/listen.socket";
        extraConfig = LT.nginx.locationProxyConf;
      };

      # Overwrite well-known info
      "= /.well-known/matrix/server".extraConfig =
        LT.nginx.locationCORSConf
        + ''
          default_type application/json;
          return 200 '${LT.constants.matrixWellKnown.server}';
        '';
      "= /.well-known/matrix/client".extraConfig =
        LT.nginx.locationCORSConf
        + ''
          default_type application/json;
          return 200 '${LT.constants.matrixWellKnown.client}';
        '';
    };
    extraConfig =
      LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  systemd.services.synapse-compress-state = {
    after = ["matrix-synapse.service"];
    requires = ["matrix-synapse.service"];
    script = ''
      exec ${pkgs.matrix-synapse-tools.rust-synapse-compress-state}/bin/synapse_auto_compressor \
        -p "host=/run/postgresql user=matrix-synapse dbname=matrix-synapse" \
        -c 500 \
        -n 100
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "matrix-synapse";
    };
  };

  systemd.timers.synapse-compress-state = {
    wantedBy = ["timers.target"];
    partOf = ["synapse-compress-state.service"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "synapse-compress-state.service";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/matrix-synapse/media 755 matrix-synapse matrix-synapse"
  ];

  users.users.matrix-sliding-sync = {
    group = "matrix-sliding-sync";
    isSystemUser = true;
  };
  users.groups.matrix-sliding-sync.members = ["nginx"];
}
