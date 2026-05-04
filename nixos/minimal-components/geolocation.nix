{
  LT,
  config,
  pkgs,
  lib,
  ...
}:
let
  where-am-i = pkgs.runCommand "where-am-i" { } ''
    mkdir -p $out/bin
    ln -sf ${pkgs.geoclue2}/libexec/geoclue-2.0/demos/where-am-i $out/bin/where-am-i
  '';
in
{
  location = {
    provider = if LT.this.hasTag LT.tags.client then "geoclue2" else "manual";
    latitude = LT.this.city.lat;
    longitude = LT.this.city.lng;
  };

  # Default geoclue2 server from Mozilla has been shut down
  services.geoclue2 = {
    enable = config.location.provider == "geoclue2";
    enableDemoAgent = true;

    enable3G = true;
    enableCDMA = true;
    enableModemGPS = true;
    enableNmea = true;
    enableWifi = true;

    geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    submitData = false;
    submissionUrl = "https://api.beacondb.net/v2/geosubmit";
    submissionNick = "lantian";
  };

  environment.systemPackages = lib.optionals config.services.geoclue2.enable [
    where-am-i
  ];
}
