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

    serviceConfig = LT.serviceHarden // {
      PrivateDevices = false;
      RestrictAddressFamilies = "";

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
}
