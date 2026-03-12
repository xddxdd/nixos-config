{
  config,
  lib,
  inputs,
  LT,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  age.secrets.n8n-secret = {
    file = inputs.secrets + "/n8n-secret.age";
    owner = "n8n";
    group = "n8n";
  };

  services.n8n = {
    enable = true;
    environment = {
      N8N_EDITOR_BASE_URL = "https://n8n.${config.networking.hostName}.xuyh0120.win";
      N8N_LISTEN_ADDRESS = "127.0.0.1";
      N8N_PORT = LT.port.N8N;
      N8N_RUNNERS_AUTH_TOKEN_FILE = config.age.secrets.n8n-secret.path;
      N8N_METRICS = true;

      DB_TYPE = "postgresdb";
      DB_POSTGRESDB_DATABASE = "n8n";
      DB_POSTGRESDB_HOST = "/run/postgresql";
      DB_POSTGRESDB_USER = "n8n";
    };
    taskRunners.enable = true;
    taskRunners.runners = {
      javascript = {
        enable = true;
        command = lib.getExe' config.services.n8n.package "n8n-task-runner";
        healthCheckPort = 5681;
      };
      python = {
        enable = true;
        command = lib.getExe' config.services.n8n.package "n8n-task-runner-python";
        healthCheckPort = 5682;
      };
    };
  };

  systemd.services.n8n.serviceConfig = {
    User = "n8n";
    Group = "n8n";
    DynamicUser = lib.mkForce false;
  };
  systemd.services.n8n-task-runner.serviceConfig = {
    User = "n8n";
    Group = "n8n";
    DynamicUser = lib.mkForce false;
  };

  services.postgresql = {
    ensureDatabases = [ "n8n" ];
    ensureUsers = [
      {
        name = "n8n";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.n8n = {
    group = "n8n";
    isSystemUser = true;
  };
  users.groups.n8n = { };

  lantian.nginxVhosts = {
    "n8n.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.N8N}";
        proxyWebsockets = true;
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
    };
    "n8n.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.N8N}";
        proxyWebsockets = true;
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
