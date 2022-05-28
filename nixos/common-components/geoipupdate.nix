{ pkgs, lib, config, ... }:

{
  age.secrets.geoipupdate-license.file = pkgs.secrets + "/geoipupdate-license.age";

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
    };
  };
}
