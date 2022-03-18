{ pkgs, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [ ./postgresql.nix ];

  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;
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
          port = LT.port.Matrix.Synapse;
          bind_addresses = [ "127.0.0.1" "::1" ];
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

  systemd.services.matrix-synapse.serviceConfig = LT.serviceHarden // {
    MemoryDenyWriteExecute = false;
    StateDirectory = "matrix-synapse";
  };

  services.postgresql = {
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensurePermissions = {
          "DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nginx.virtualHosts."matrix.lantian.pub" = {
    listen = LT.nginx.listenHTTPSPort LT.port.Matrix.Public;
    serverAliases = [ config.services.matrix-synapse.settings.server_name ];
    locations = LT.nginx.addNoIndexLocationConf {
      "/" = {
        proxyPass = "http://[::1]:${LT.portStr.Matrix.Synapse}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
