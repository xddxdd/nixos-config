{
  lib,
  math,
  sanitizeName,
  translit,
  inputs,
  ...
}: let
  citiesJson = builtins.fromJSON (builtins.readFile (inputs.cities-json + "/cities.json"));
in rec {
  cities =
    builtins.listToAttrs
    (builtins.map
      (args: let
        # Mark entire China region as CN
        country =
          if builtins.elem args.country ["CN" "HK" "MO" "TW"]
          then "CN"
          else args.country;
        name = translit args.name;
      in
        lib.nameValuePair "${country} ${name}" (args
          // {
            sanitized = sanitizeName "${country} ${name}";
          }))
      citiesJson);

  distance = a: b:
    math.haversine
    (math.parseFloat a.lat)
    (math.parseFloat a.lng)
    (math.parseFloat b.lat)
    (math.parseFloat b.lng);

  rttMs = a: b: math.floor ((distance a b) / 150000);
}
