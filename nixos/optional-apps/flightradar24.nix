{
  pkgs,
  lib,
  LT,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./dump1090.nix
    ./dump978.nix
  ];

  age.secrets.flightradar24-key = {
    file = inputs.secrets + "/flightradar24-key.age";
    owner = "fr24";
    group = "fr24";
  };
  age.secrets.flightradar24-uat-key = {
    file = inputs.secrets + "/flightradar24-uat-key.age";
    owner = "fr24";
    group = "fr24";
  };

  environment.systemPackages = [ pkgs.nur-xddxdd.fr24feed ];

  systemd.services.fr24feed = {
    description = "Flightradar24 Feeder";
    after = [
      "network.target"
      "dump1090.service"
    ];
    requires = [
      "dump1090.service"
    ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${lib.getExe pkgs.nur-xddxdd.fr24feed} \
        --monitor-file=/run/fr24feed/decoder.txt \
        --fr24key=$(cat ${config.age.secrets.flightradar24-key.path}) \
        --bs=no \
        --raw=no \
        --mlat=no \
        --mlat-without-gps=no \
        --receiver=beast-tcp \
        --host=127.0.0.1:${LT.portStr.Dump1090.BeastOutput}
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
        --fr24key=$(cat ${config.age.secrets.flightradar24-uat-key.path}) \
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
