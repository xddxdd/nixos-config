{
  lib,
  pkgs,
  ...
}:
{
  imports = [ ../postgresql.nix ];

  services.postgresql = {
    ensureDatabases = [ "pyhss" ];
    ensureUsers = [
      {
        name = "pyhss";
        ensureDBOwnership = true;
      }
    ];
  };

  services.redis.servers.pyhss = {
    enable = true;
    databases = 1;
    user = "pyhss";
    group = "pyhss";
  };

  environment.etc."pyhss".source = ./pyhss;

  systemd.services = builtins.listToAttrs (
    builtins.map
      (
        svc:
        lib.nameValuePair "pyhss-${svc}" {
          description = "PyHSS ${svc} server";
          requires = [
            "redis-pyhss.service"
            "postgresql.service"
          ];
          after = [
            "redis-pyhss.service"
            "postgresql.service"
          ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            User = "pyhss";
            Group = "pyhss";

            ExecStart = "${pkgs.nur-xddxdd.pyhss}/bin/${svc}Service";

            LogsDirectory = "pyhss";
            RuntimeDirectory = "pyhss-${svc}";
            WorkingDirectory = "/run/pyhss-${svc}";

            Restart = "always";
            RestartSec = "5";
          };
        }
      )
      [
        "api"
        "diameter"
        "hss"
      ]
  );

  users.users.pyhss = {
    group = "pyhss";
    isSystemUser = true;
  };
  users.groups.pyhss = { };

  lantian.localVhosts.pyhss = {
    locations = {
      "/".proxyPass = "http://127.0.0.8:8080";
      "/swaggerui/".alias =
        "${pkgs.python3Packages.flask-swagger-ui}/lib/python${pkgs.python3.pythonVersion}/site-packages/flask_swagger_ui/dist/";
      "= /".return = "302 /docs/";
    };
  };
}
