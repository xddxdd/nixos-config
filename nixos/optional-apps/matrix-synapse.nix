{ pkgs, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [ ./postgresql.nix ];

  services.matrix-synapse = {
    enable = true;
    database_type = "psycopg2";
    database_user = "matrix-synapse";
    database_name = "matrix-synapse";
    public_baseurl = "https://${config.services.matrix-synapse.server_name}:${LT.portStr.Matrix.Public}/";
    server_name = config.networking.domain;
    listeners = [
      {
        port = LT.port.Matrix.Synapse;
        bind_address = "::1";
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
    url_preview_enabled = true;
    withJemalloc = true;
    extraConfig = ''
      max_upload_size: "500M"
    '';
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
    serverAliases = [ config.services.matrix-synapse.server_name ];
    locations = LT.nginx.addCommonLocationConf {
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
