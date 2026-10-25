{
  pkgs,
  lib,
  LT,
  ...
}:
{
  systemd.services.dump978 = {
    description = "dump978 UAT receiver";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      PrivateDevices = false;
      RestrictAddressFamilies = "";

      # Direct SDR access needs USB device ioctls on nodes owned by the
      # initial user namespace; user namespace would break them
      PrivateUsers = false;

      User = "adsb";
      Group = "adsb";

      Restart = "always";
      RestartSec = "5";

      ExecStart = builtins.concatStringsSep " " [
        (lib.getExe pkgs.nur-xddxdd.dump978)
        "--sdr driver=rtlsdr,serial=stx:978:0"
        "--raw-port ${LT.portStr.ADSB.RawOutput978}"
      ];
    };
  };

  lantian.harden.dump978.enable = true;
}
