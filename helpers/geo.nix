{ pkgs, lib, sanitizeName, inputs, ... }:

let
  citiesJson = builtins.fromJSON (builtins.readFile (inputs.cities-json + "/cities.json"));
in
rec {
  cities = builtins.listToAttrs
    (builtins.map
      ({ country, name, ... }@args: lib.nameValuePair "${country} ${name}" (args // {
        sanitized = sanitizeName "${country} ${name}";
      }))
      citiesJson);

  distance = a: b:
    let
      py = pkgs.python3.withPackages (p: with p; [ geopy ]);
    in
    lib.toInt (builtins.readFile (pkgs.runCommandLocal "geo-result.txt" { } ''
      ${py}/bin/python > $out <<EOF
      import geopy.distance
      print(int(geopy.distance.geodesic((${a.lat}, ${a.lng}), (${b.lat}, ${b.lng})).km))
      EOF
    ''));

  rttMs = a: b: (distance a b) / 150;
}
