{
  pkgs,
  lib,
  config,
  ...
}:
let
  qqwryDB = pkgs.fetchurl {
    url = "https://github.com/out0fmemory/qqwry.dat/raw/master/qqwry_lastest.dat";
    hash = "sha256-ZfzgGSd+hOIFvqAgKE6GajZwN4GaDRx+awqYwMPh5kI=";
  };
in
{
  options.lantian.geoip.enable = lib.mkEnableOption "GeoIP Databases";

  config = lib.mkIf config.lantian.geoip.enable {
    environment.etc."geoip".source = pkgs.symlinkJoin {
      name = "geoip";
      paths = [
        pkgs.nur-xddxdd.dbip-lite
        pkgs.nur-xddxdd.geolite2
      ];
    };

    environment.etc."qqwry/qqwry.dat".source = qqwryDB;
  };
}
