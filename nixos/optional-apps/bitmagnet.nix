{
  pkgs,
  inputs,
  LT,
  config,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  age.secrets.tmdb-api-key = {
    file = inputs.secrets + "/tmdb-api-key.age";
    owner = "bitmagnet";
    group = "bitmagnet";
  };

  systemd.services.bitmagnet = {
    description = "BitMagnet";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    environment = {
      POSTGRES_HOST = "/run/postgresql";
      POSTGRES_NAME = "bitmagnet";
      POSTGRES_USER = "bitmagnet";
      TMDB_ENABLED = "true";
    };
    script = ''
      export TMDB_API_KEY=$(cat ${config.age.secrets.tmdb-api-key.path})
      exec ${pkgs.bitmagnet}/bin/bitmagnet worker run --all
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

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
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
