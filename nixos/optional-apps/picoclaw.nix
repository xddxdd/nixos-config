{
  lib,
  pkgs,
  LT,
  ...
}:
{
  environment.systemPackages = [ pkgs.picoclaw ];

  systemd.services.picoclaw = {
    description = "PicoClaw";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${lib.getExe pkgs.picoclaw} gateway";
      User = "picoclaw";
      Group = "picoclaw";

      MemoryDenyWriteExecute = false;
      StateDirectory = "picoclaw";

      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.picoclaw = {
    group = "picoclaw";
    isSystemUser = true;
    home = "/var/lib/picoclaw";
  };
  users.groups.picoclaw = { };
}
