{
  pkgs,
  lib,
  LT,
  config,
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

      Restart = "always";
      RestartSec = "5";

      ExecStart = builtins.concatStringsSep " " [
        "${lib.getExe pkgs.nur-xddxdd.dump978}"
        "--sdr driver=rtlsdr,serial=stx:978:0"
        "--raw-port ${LT.portStr.Dump978.Raw}"
        "--json-port ${LT.portStr.Dump978.Json}"
      ];
    };
  };

  systemd.services.skyaware978 = {
    description = "skyaware978 UAT receiver";
    after = [
      "network.target"
      "dump978.service"
    ];
    requires = [ "dump978.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      RuntimeDirectory = "skyaware978";
      RuntimeDirectoryMode = "755";
      WorkingDirectory = "/run/skyaware978";

      Restart = "always";
      RestartSec = "5";

      ExecStart = builtins.concatStringsSep " " [
        "${lib.getExe' pkgs.nur-xddxdd.dump978 "skyaware978"}"
        "--connect 127.0.0.1:${LT.portStr.Dump978.Raw}"
        "--reconnect-interval 5"
        "--json-dir /run/skyaware978"
        "--lat ${LT.this.city.lat}"
        "--lon ${LT.this.city.lng}"
      ];
    };
  };

  lantian.nginxVhosts."dump978.${config.networking.hostName}.xuyh0120.win" = {
    root = "${pkgs.dump1090-fa}/share/dump1090";
    locations = {
      "/data/".alias = "/run/skyaware978/";
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
