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

  services.geoclue2.enable = LT.this.hasTag LT.tags.client;
}
