{
  lib,
  LT,
  pkgs,
  ...
}:
{
  systemd.services.pi-web = {
    description = "Pi Web";
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.git ];

    environment = {
      PORT = LT.portStr.PiWeb;
      PI_WEB_HOSTNAME = "127.0.0.1";
      PI_WEB_NO_OPEN = "1";
      PI_WEB_ALLOWED_HOSTS = "pi-web.localhost";
    };

    serviceConfig = {
      ExecStart = lib.getExe pkgs.nur-xddxdd.pi-web;
      User = "lantian";
      Group = "lantian";

      Restart = "always";
      RestartSec = "5";
    };
  };

  lantian.localVhosts.pi-web = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.PiWeb}";
        proxyWebsockets = true;
        proxyOverrideHost = "pi-web.localhost";
        proxyNoTimeout = true;
      };
    };
  };
}
