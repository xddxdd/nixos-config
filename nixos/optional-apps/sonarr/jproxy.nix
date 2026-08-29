{
  pkgs,
  lib,
  LT,
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

  lantian.localVhosts.jproxy = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.JProxy}";
      };
    };
  };
}
