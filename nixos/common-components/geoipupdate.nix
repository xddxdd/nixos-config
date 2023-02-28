{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
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
    };
  };
}
