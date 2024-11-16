{
  LT,
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
    enable = LT.this.hasTag LT.tags.client;
    geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    submitData = false;
    submissionUrl = "https://api.beacondb.net/v2/geosubmit";
    submissionNick = "lantian";
  };
}
