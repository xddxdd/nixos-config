{
  LT,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  services.postgresql = {
    ensureDatabases = [ "axonhub" ];
    ensureUsers = [
      {
        name = "axonhub";
        ensureDBOwnership = true;
      }
    ];
  };

  services.redis.servers.axonhub = {
    enable = true;
    port = LT.port.AxonHub.Redis;
    databases = 1;
    user = "axonhub";
  };

  systemd.services.axonhub = {
    description = "AxonHub";
    after = [
      "network.target"
      "redis-axonhub.service"
      "postgresql.service"
    ];
    requires = [
      "redis-axonhub.service"
      "postgresql.service"
    ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      AXONHUB_SERVER_PORT = LT.portStr.AxonHub.Web;
      AXONHUB_DB_DIALECT = "postgres";
      AXONHUB_DB_DSN = "postgres:///axonhub?host=/run/postgresql&user=axonhub";
      AXONHUB_CACHE_MODE = "redis";
      AXONHUB_CACHE_REDIS_URL = "redis://localhost:${LT.portStr.AxonHub.Redis}/0";
    };

    serviceConfig = LT.serviceHarden // {
      ExecStart = lib.getExe pkgs.nur-xddxdd.axonhub;
      Restart = "always";
      RestartSec = "5";
      User = "axonhub";
      Group = "axonhub";
    };
  };

  users.users.axonhub = {
    group = "axonhub";
    isSystemUser = true;
  };
  users.groups.axonhub = { };

  lantian.nginxVhosts."axonhub.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.AxonHub.Web}";
        proxyNoTimeout = true;
        proxyWebsockets = true;
      };
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
