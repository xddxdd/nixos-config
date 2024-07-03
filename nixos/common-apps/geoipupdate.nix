{
  config,
  inputs,
  lib,
  ...
}:
lib.mkIf config.services.rsyncd.enable {
  age.secrets.geoipupdate-license.file = inputs.secrets + "/geoipupdate-license.age";

  services.geoipupdate = {
    enable = true;
    settings = {
      LicenseKey = config.age.secrets.geoipupdate-license.path;
      AccountID = 169840;
      EditionIDs = [
        "GeoLite2-ASN"
        "GeoLite2-City"
        "GeoLite2-Country"
      ];
      DatabaseDirectory = "/nix/persistent/sync-servers/geoip";
    };
  };
}
