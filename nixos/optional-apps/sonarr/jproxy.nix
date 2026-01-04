{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  systemd.services.jproxy = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "radarr.service"
      "sonarr.service"
    ];
    requires = [
      "radarr.service"
      "sonarr.service"
    ];

    script = ''
      mkdir -p config database
      if [ ! -f config/application.yml ]; then
        ${lib.getExe' pkgs.coreutils "install"} -Dm755 ${pkgs.nur-xddxdd.jproxy}/opt/config/application.yml config/application.yml
      fi
      if [ ! -f config/application-prod.yml ]; then
        ${lib.getExe' pkgs.coreutils "install"} -Dm755 ${pkgs.nur-xddxdd.jproxy}/opt/config/application-prod.yml config/application-prod.yml
      fi
      if [ ! -f database/jproxy.db ]; then
        ${lib.getExe' pkgs.coreutils "install"} -Dm755 ${pkgs.nur-xddxdd.jproxy}/opt/database/jproxy.db database/jproxy.db
      fi

      exec ${lib.getExe pkgs.nur-xddxdd.jproxy} -Dspring.config.location=/var/lib/jproxy/
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "5";

      MemoryDenyWriteExecute = false;

      StateDirectory = "jproxy";
      WorkingDirectory = "/var/lib/jproxy";

      User = "lantian";
      Group = "users";
    };
  };

  lantian.nginxVhosts = {
    "jproxy.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.JProxy}";
        };
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
    };
    "jproxy.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.JProxy}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
