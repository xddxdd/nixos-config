{
  pkgs,
  LT,
  config,
  ...
}:
{
  systemd.services.dump1090 = {
    description = "dump1090 ADS-B receiver";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${pkgs.dump1090}/bin/dump1090 \
        --quiet \
        --device stx:1090:0 \
        --net \
        --net-bind-address 127.0.0.1 \
        --net-ri-port ${LT.portStr.Dump1090.RawInput} \
        --net-ro-port ${LT.portStr.Dump1090.RawOutput} \
        --net-sbs-port ${LT.portStr.Dump1090.BaseStation} \
        --net-bi-port ${LT.portStr.Dump1090.BeastInput} \
        --net-bo-port ${LT.portStr.Dump1090.BeastOutput} \
        --net-stratux-port ${LT.portStr.Dump1090.Stratux} \
        --write-json /run/dump1090 \
        --forward-mlat \
        --lat ${LT.this.city.lat} \
        --lon ${LT.this.city.lng}
    '';

    serviceConfig = LT.serviceHarden // {
      PrivateDevices = false;
      RestrictAddressFamilies = "";

      RuntimeDirectory = "dump1090";
      RuntimeDirectoryMode = "755";
      WorkingDirectory = "/run/dump1090";

      Restart = "always";
      RestartSec = "5";
    };
  };

  lantian.nginxVhosts."dump1090.${config.networking.hostName}.xuyh0120.win" = {
    root = "${pkgs.dump1090}/share/dump1090";
    locations = {
      "/data/".alias = "/run/dump1090/";
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
