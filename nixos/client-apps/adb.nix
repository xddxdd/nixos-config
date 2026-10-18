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
      # adb server stores its keys and state under /root/.android; bind it
      # through the chroot (preserved on the host)
      BindPaths = [ "/root/.android" ];
      BindReadOnlyPaths = [ "/etc/localtime" ];
    };

    confinement = { enable = true; fullUnit = true; };
  };

  users.users.lantian.extraGroups = [ "adbusers" ];

  lantian.preservation.directories = [ "/root/.android" ];
}
