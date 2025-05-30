{
  pkgs,
  LT,
  config,
  ...
}:
{
  imports = [ ./mysql.nix ];

  systemd.services.one-api = {
    description = "One-API Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      SQL_DSN = "one-api@unix(/run/mysqld/mysqld.sock)/one-api";
    };

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${pkgs.nur-xddxdd.one-api}/bin/one-api --port ${LT.portStr.OneAPI}";
      Restart = "always";
      RestartSec = "3";

      StateDirectory = "one-api";
      WorkingDirectory = "/var/lib/one-api";

      User = "one-api";
      Group = "one-api";
    };
  };

  services.mysql = {
    ensureDatabases = [ "one-api" ];
    ensureUsers = [
      {
        name = "one-api";
        ensurePermissions = {
          "\\`one-api\\`.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  users.users.one-api = {
    group = "one-api";
    isSystemUser = true;
  };
  users.groups.one-api.members = [ "nginx" ];

  lantian.nginxVhosts = {
    "one-api.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OneAPI}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "one-api.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OneAPI}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
