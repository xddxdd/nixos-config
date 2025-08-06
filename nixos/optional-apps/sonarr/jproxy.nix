{
  pkgs,
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
        ${pkgs.coreutils}/bin/install -Dm755 ${pkgs.nur-xddxdd.jproxy}/opt/config/application.yml config/application.yml
      fi
      if [ ! -f config/application-prod.yml ]; then
        ${pkgs.coreutils}/bin/install -Dm755 ${pkgs.nur-xddxdd.jproxy}/opt/config/application-prod.yml config/application-prod.yml
      fi
      if [ ! -f database/jproxy.db ]; then
        ${pkgs.coreutils}/bin/install -Dm755 ${pkgs.nur-xddxdd.jproxy}/opt/database/jproxy.db database/jproxy.db
      fi

      exec ${pkgs.nur-xddxdd.jproxy}/bin/jproxy -Dspring.config.location=/var/lib/jproxy/
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
