{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [ ./postgresql.nix ];

  services.matrix-synapse = {
    enable = true;
    settings = {
      max_upload_size = "500M";
      public_baseurl = "https://matrix.lantian.pub:${LT.portStr.Matrix.Public}";
      server_name = config.networking.domain;
      url_preview_enabled = true;
      account_threepid_delegates = {
        email = "https://vector.im";
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
          bind_addresses = [ "/run/matrix-synapse/matrix-synapse.sock" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = false;
            }
          ];
        }
      ];
    };
  };

  systemd.services.matrix-synapse = {
    environment = {
      LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
    };
    serviceConfig = LT.serviceHarden // {
      MemoryDenyWriteExecute = false;
      StateDirectory = "matrix-synapse";
      RuntimeDirectory = "matrix-synapse";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [{
      name = "matrix-synapse";
      ensurePermissions = {
        "DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
      };
    }];
  };

  services.nginx.virtualHosts."matrix.lantian.pub" = {
    listen = LT.nginx.listenHTTPSPort LT.port.Matrix.Public;
    serverAliases = [ config.services.matrix-synapse.settings.server_name ];
    locations = LT.nginx.addCommonLocationConf { } {
      "/" = {
        proxyPass = "http://unix:/run/matrix-synapse/matrix-synapse.sock";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  systemd.services.synapse-compress-state = {
    after = [ "matrix-synapse.service" ];
    requires = [ "matrix-synapse.service" ];
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
    wantedBy = [ "timers.target" ];
    partOf = [ "synapse-compress-state.service" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "synapse-compress-state.service";
    };
  };
}
