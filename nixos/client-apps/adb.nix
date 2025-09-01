{ pkgs, LT, ... }:
let
  adbPackage = pkgs.androidenv.androidPkgs.androidsdk;
in
{
  services.udev.packages = [ pkgs.android-udev-rules ];
  environment.systemPackages = [ adbPackage ];
  users.groups.adbusers.members = [ "lantian" ];

  systemd.services.adbd = {
    description = "ADB Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      User = "root";
      ExecStart = "${adbPackage}/bin/adb start-server";
      ExecStop = "${adbPackage}/bin/adb kill-server";
      Restart = "always";
      RestartSec = 5;
    };
  };

  preservation.preserveAt."/nix/persistent" = {
    users.root = {
      home = "/root";
      directories = builtins.map LT.preservation.mkFolder [ ".android" ];
    };
  };
}
