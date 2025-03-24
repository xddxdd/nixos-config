{
  LT,
  config,
  ...
}:
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
}
