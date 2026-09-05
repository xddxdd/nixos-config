{
  pkgs,
  lib,
  LT,
  ...
}:
let
  dlx = pkgs.nur-xddxdd.dlx.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/dlx-fingerprint.patch
    ];
  });
in
{
  systemd.services.dlx = {
    description = "DLX";
    wantedBy = [ "multi-user.target" ];

    environment = {
      IP = "127.0.0.1";
      PORT = LT.portStr.DLX;
    };

    serviceConfig = LT.serviceHarden // {
      ExecStart = lib.getExe dlx;
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
