{ pkgs,
  lib, LT, ... }:
{
  programs.adb.enable = true;

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

  preservation.preserveAt."/nix/persistent" = {
    users.root = {
      home = "/root";
      directories = builtins.map LT.preservation.mkFolder [ ".android" ];
    };
  };
}
