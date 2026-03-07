{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = [ pkgs.android-tools ];

  systemd.services.adbd = {
    description = "ADB Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      User = "root";
      ExecStart = "${lib.getExe' pkgs.android-tools "adb"} start-server";
      ExecStop = "${lib.getExe' pkgs.android-tools "adb"} kill-server";
      Restart = "always";
      RestartSec = 5;
    };
  };

  users.users.lantian.extraGroups = [ "adbusers" ];

  lantian.preservation.directories = [ "/root/.android" ];
}
