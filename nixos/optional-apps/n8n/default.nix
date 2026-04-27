{
  config,
  lib,
  inputs,
  LT,
  ...
}:
{
  imports = [
    ../postgresql.nix
    ./n8n-openai-bridge.nix
  ];

  sops.secrets.n8n-secret = {
    sopsFile = inputs.secrets + "/n8n.yaml";
    owner = "n8n";
    group = "n8n";
  };

  services.n8n = {
    enable = true;
    environment = {
      N8N_EDITOR_BASE_URL = "https://n8n.xuyh0120.win";
      N8N_LISTEN_ADDRESS = "127.0.0.1";
      N8N_PORT = LT.port.N8N;
      N8N_RUNNERS_AUTH_TOKEN_FILE = config.sops.secrets.n8n-secret.path;
      N8N_METRICS = true;
      N8N_RESTRICT_FILE_ACCESS_TO = "/var/cache/n8n";

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
        environment = {
          NODE_FUNCTION_ALLOW_BUILTIN = "*";
          NODE_FUNCTION_ALLOW_EXTERNAL = "*";
        };
      };
      python = {
        enable = true;
        command = lib.getExe' config.services.n8n.package "n8n-task-runner-python";
        healthCheckPort = 5682;
        environment = {
          N8N_RUNNERS_STDLIB_ALLOW = "*";
          N8N_RUNNERS_EXTERNAL_ALLOW = "*";
          N8N_RUNNERS_BUILTINS_DENY = "";
        };
      };
    };
  };

  systemd.services.n8n.serviceConfig = {
    User = "n8n";
    Group = "n8n";
    DynamicUser = lib.mkForce false;
    Restart = lib.mkForce "always";
    CacheDirectory = "n8n";
  };
  systemd.services.n8n-task-runner.serviceConfig = {
    User = "n8n";
    Group = "n8n";
    DynamicUser = lib.mkForce false;
    Restart = lib.mkForce "always";
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

  lantian.nginxVhosts."n8n.xuyh0120.win" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.N8N}";
      proxyWebsockets = true;
    };
    locations."/webhook/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.N8N}";
      proxyWebsockets = true;
      extraConfig = ''
        allow 127.0.0.1;
        allow ::1;
        deny all;
      '';
    };

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
  };
}
