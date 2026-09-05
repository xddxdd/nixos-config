{
  pkgs,
  lib,
  LT,
  ...
}:
{
  systemd.services.dlx = {
    description = "DLX";
    wantedBy = [ "multi-user.target" ];

    environment = {
      IP = "127.0.0.1";
      PORT = LT.portStr.DLX;
    };

    serviceConfig = LT.serviceHarden // {
      ExecStart = lib.getExe pkgs.nur-xddxdd.dlx;
      User = "dlx";
      Group = "dlx";

      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.dlx = {
    group = "dlx";
    isSystemUser = true;
  };
  users.groups.dlx = { };

  lantian.localVhosts.dlx = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.DLX}";
        proxyNoTimeout = true;
      };
    };
  };
}
