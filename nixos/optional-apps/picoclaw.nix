{
  lib,
  pkgs,
  LT,
  config,
  ...
}:
{
  environment.systemPackages = [
    pkgs.github-cli
    pkgs.picoclaw
  ];

  systemd.services.picoclaw = {
    description = "PicoClaw";
    wantedBy = [ "multi-user.target" ];

    path = config.environment.systemPackages;

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
