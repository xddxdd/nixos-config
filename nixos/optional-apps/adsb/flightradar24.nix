{
  pkgs,
  lib,
  LT,
  inputs,
  config,
  ...
}:
{
  sops.secrets.adsb-flightradar24-key = {
    sopsFile = inputs.secrets + "/adsb.yaml";
    owner = "fr24";
    group = "fr24";
  };
  sops.secrets.adsb-flightradar24-uat-key = {
    sopsFile = inputs.secrets + "/adsb.yaml";
    owner = "fr24";
    group = "fr24";
  };

  environment.systemPackages = [ pkgs.nur-xddxdd.fr24feed ];

  systemd.services.fr24feed = {
    description = "Flightradar24 Feeder";
    after = [
      "network.target"
      "podman-adsb-ultrafeeder.service"
    ];
    requires = [
      "podman-adsb-ultrafeeder.service"
    ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${lib.getExe pkgs.nur-xddxdd.fr24feed} \
        --monitor-file=/run/fr24feed/decoder.txt \
        --fr24key=$(cat ${config.sops.secrets.adsb-flightradar24-key.path}) \
        --bs=no \
        --raw=no \
        --mlat=no \
        --mlat-without-gps=no \
        --receiver=beast-tcp \
        --host=${LT.this.ltnet.IPv4}:${LT.portStr.Dump1090.BeastOutput}
    '';

    serviceConfig = {
      User = "fr24";
      Group = "fr24";

      RuntimeDirectory = "fr24feed";

      Restart = "always";
      RestartSec = "5";
    };
  };

  systemd.services.fr24uat-feed = {
    description = "Flightradar24 UAT Feeder";
    after = [
      "network.target"
      "dump978.service"
    ];
    requires = [
      "dump978.service"
    ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${lib.getExe pkgs.nur-xddxdd.fr24feed} \
        --monitor-file=/run/fr24uat-feed/decoder.txt \
        --fr24key=$(cat ${config.sops.secrets.adsb-flightradar24-uat-key.path}) \
        --http-listen-port=8755 \
        --unit=fr24uat-feed \
        --receiver=uat-tcp \
        --uat-port="${LT.portStr.Dump978.Raw}"
    '';

    serviceConfig = {
      User = "fr24";
      Group = "fr24";

      RuntimeDirectory = "fr24uat-feed";

      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.fr24 = {
    group = "fr24";
    isSystemUser = true;
  };
  users.groups.fr24 = { };
}
