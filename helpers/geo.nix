{ pkgs, lib, sanitizeName, inputs, ... }:

let
  citiesJson = builtins.fromJSON (builtins.readFile (inputs.cities-json + "/cities.json"));
in
rec {
  cities = builtins.listToAttrs
    (builtins.map
      (args:
        let
          # Mark entire China region as CN
          country = if builtins.elem args.country [ "CN" "HK" "MO" "TW" ] then "CN" else args.country;
          name = args.name;
        in
        lib.nameValuePair "${country} ${name}" (args // {
          sanitized = sanitizeName "${country} ${name}";
        }))
      citiesJson);

  distance = a: b:
    let
      py = pkgs.python3.withPackages (p: with p; [ geopy ]);

      helper = a: b: lib.toInt (builtins.readFile (pkgs.runCommandLocal "geo-result.txt" { } ''
        ${py}/bin/python > $out <<EOF
        import geopy.distance
        print(int(geopy.distance.geodesic((${a.lat}, ${a.lng}), (${b.lat}, ${b.lng})).km))
        EOF
      ''));
    in
    if a.lat < b.lat || (a.lat == b.lat && a.lng < b.lng) then helper a b else helper b a;

  rttMs = a: b: (distance a b) / 150;
}
