{
  lib,
  pkgs,
  ...
}:
let
  pyhss = pkgs.nur-xddxdd.pyhss.overrideAttrs (old: {
    # Match the OriginHost Redis namespace used by diameterService/hssService.
    postPatch = (old.postPatch or "") + ''
      substituteInPlace services/apiService.py \
        --replace-fail 'originHostname = socket.gethostname()' "originHostname = config['hss']['OriginHost']"
      substituteInPlace lib/diameter.py \
        --replace-fail 'self.hostname = socket.gethostname()' 'self.hostname = originHost'
    '';
  });
in
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

  # diameter.py loads XML templates from both ../ and ./ relative to cwd.
  environment.etc."pyhss".source = pkgs.runCommand "pyhss-config" { } ''
    mkdir -p "$out/services"
    cp ${./pyhss}/* "$out/"
    ln -s ../default_sh_user_data.xml "$out/services/default_sh_user_data.xml"
  '';

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
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            User = "pyhss";
            Group = "pyhss";

            ExecStart = "${pyhss}/bin/${svc}Service";

            LogsDirectory = "pyhss";
            WorkingDirectory = "/etc/pyhss/services";
            IPAddressDeny = "any";
            IPAddressAllow = "localhost";

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

  lantian.harden =
    lib.genAttrs
      [
        "pyhss-api"
        "pyhss-diameter"
        "pyhss-hss"
      ]
      (_: {
        enable = true;
        postgresql = true;
        redis = "pyhss";
        etc.pyhss = true;
      });

  lantian.localVhosts.pyhss = {
    accessibleBy = "private";
    locations = {
      "/".proxyPass = "http://127.0.0.8:8080";
      "/swaggerui/".alias =
        "${pkgs.python3Packages.flask-swagger-ui}/lib/python${pkgs.python3.pythonVersion}/site-packages/flask_swagger_ui/dist/";
      "= /".return = "302 /docs/";
    };
  };
}
