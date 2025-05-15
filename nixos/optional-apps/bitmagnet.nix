{
  pkgs,
  inputs,
  LT,
  config,
  ...
}:
let
  inherit (pkgs) bitmagnet;

  mkBitmagnetService = worker: {
    description = "BitMagnet ${worker}";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
    ];
    wants = [
      "network.target"
      "postgresql.service"
    ];
    environment = {
      POSTGRES_HOST = "/run/postgresql";
      POSTGRES_NAME = "bitmagnet";
      POSTGRES_USER = "bitmagnet";
      TMDB_ENABLED = "true";
    };
    script = ''
      export TMDB_API_KEY=$(cat ${config.age.secrets.tmdb-api-key.path})
      export PROCESSOR_CONCURRENCY=$(nproc)
      exec ${bitmagnet}/bin/bitmagnet worker run --keys=${worker}
    '';
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      RuntimeDirectory = "bitmagnet";
      StateDirectory = "bitmagnet";
      WorkingDirectory = "/var/lib/bitmagnet";

      User = "bitmagnet";
      Group = "bitmagnet";
    };
  };
in
{
  imports = [ ./postgresql.nix ];

  age.secrets.tmdb-api-key = {
    file = inputs.secrets + "/tmdb-api-key.age";
    owner = "bitmagnet";
    group = "bitmagnet";
  };

  systemd.services.bitmagnet-http = mkBitmagnetService "http_server";
  systemd.services.bitmagnet-queue = mkBitmagnetService "queue_server";
  systemd.services.bitmagnet-dht = mkBitmagnetService "dht_crawler";

  services.postgresql = {
    ensureDatabases = [ "bitmagnet" ];
    ensureUsers = [
      {
        name = "bitmagnet";
        ensureDBOwnership = true;
      }
    ];
  };

  lantian.nginxVhosts = {
    "bitmagnet.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Bitmagnet}";
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "bitmagnet.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Bitmagnet}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };

  users.users.bitmagnet = {
    group = "bitmagnet";
    isSystemUser = true;
  };
  users.groups.bitmagnet = { };
}
