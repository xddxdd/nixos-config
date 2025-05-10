{ pkgs, LT, ... }:
{
  programs.adb.enable = true;

  systemd.services.adbd = {
    description = "ADB Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      User = "root";
      ExecStart = "${pkgs.android-tools}/bin/adb start-server";
      ExecStop = "${pkgs.android-tools}/bin/adb kill-server";
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
