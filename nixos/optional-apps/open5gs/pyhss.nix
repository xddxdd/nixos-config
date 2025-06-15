{
  config,
  lib,
  pkgs,
  ...
}:
let
  pyhss = pkgs.nur-xddxdd.pyhss.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace services/apiService.py \
          --replace-fail "0.0.0.0" "127.0.0.8"
      '';
  });
in
{
  services.redis.servers.pyhss = {
    enable = true;
    databases = 1;
    user = "pyhss";
    group = "pyhss";
  };

  systemd.services = builtins.listToAttrs (
    builtins.map
      (
        svc:
        lib.nameValuePair "pyhss-${svc}" {
          description = "PyHSS ${svc} server";
          requires = [ "redis-pyhss.service" ];
          after = [ "redis-pyhss.service" ];
          wantedBy = [ "multi-user.target" ];

          script = ''
            ln -sf ${./pyhss.yaml} config.yaml
            ln -sf ${pyhss}/opt/default_ifc.xml default_ifc.xml
            ln -sf ${pyhss}/opt/default_sh_user_data.xml default_sh_user_data.xml

            exec ${pyhss}/bin/${svc}Service
          '';

          serviceConfig = {
            User = "pyhss";
            Group = "pyhss";

            StateDirectory = "pyhss";
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

  lantian.nginxVhosts = {
    "pyhss.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/".proxyPass = "http://127.0.0.8:8080";
        "/swaggerui/".alias =
          "${pkgs.python3Packages.flask-swagger-ui}/lib/python${pkgs.python3.pythonVersion}/site-packages/flask_swagger_ui/dist/";
        "= /".return = "302 /docs/";
      };

      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "pyhss.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/".proxyPass = "http://127.0.0.8:8080";
        "/swaggerui/".alias =
          "${pkgs.python3Packages.flask-swagger-ui}/lib/python${pkgs.python3.pythonVersion}/site-packages/flask_swagger_ui/dist/";
        "= /".return = "302 /docs/";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
