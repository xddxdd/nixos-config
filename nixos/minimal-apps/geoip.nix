{ pkgs, ... }:
{
  environment.etc."geoip".source = pkgs.symlinkJoin {
    name = "geoip";
    paths = [
      pkgs.nur-xddxdd.dbip-lite
      pkgs.nur-xddxdd.geolite2
    ];
  };
}
