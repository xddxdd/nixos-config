{ pkgs, ... }:
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
    };
  };

  users.users.lantian.extraGroups = [ "adbusers" ];
}
