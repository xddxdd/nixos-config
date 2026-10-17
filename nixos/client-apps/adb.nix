{
  pkgs,
  lib,
  LT,
  ...
}:
{
  environment.systemPackages = [ pkgs.android-tools ];

  systemd.services.adbd = {
    description = "ADB Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "forking";
      User = "root";
      # adbd needs to open USB/network ADB transport sockets
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      ExecStart = "${lib.getExe' pkgs.android-tools "adb"} start-server";
      ExecStop = "${lib.getExe' pkgs.android-tools "adb"} kill-server";
      Restart = "always";
      RestartSec = 5;
    };
  };

  users.users.lantian.extraGroups = [ "adbusers" ];

  lantian.preservation.directories = [ "/root/.android" ];
}
