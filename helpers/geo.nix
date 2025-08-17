{
  lib,
  math,
  sanitizeName,
  translit,
  ...
}:
let
  # Subset of https://raw.githubusercontent.com/lutangar/cities.json/refs/heads/master/cities.json
  citiesJson = lib.importJSON ./cities.json;
in
rec {
  cities = builtins.listToAttrs (
    builtins.map (
      args:
      let
        # Mark entire China region as CN
        country =
          if
            builtins.elem args.country [
              "CN"
              "HK"
              "MO"
              "TW"
            ]
          then
            "CN"
          else
            args.country;
        name = translit args.name;
      in
      lib.nameValuePair "${country} ${name}" (
        args
        // {
          inherit country;
          sanitized = sanitizeName "${country} ${name}";
        }
      )
    ) citiesJson
  );

  distance =
    a: b:
    math.haversine (math.parseFloat a.lat) (math.parseFloat a.lng) (math.parseFloat b.lat) (
      math.parseFloat b.lng
    );

  rttMs = a: b: math.floor ((distance a b) / 150000);
}
