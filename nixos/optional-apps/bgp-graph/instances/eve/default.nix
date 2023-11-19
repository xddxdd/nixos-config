{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  data = lib.importJSON ./universe-pretty.json;

  ID_OFFSET = 30000000;
  DISTANCE_RATIO = 1000000;

  idToCoordinate = builtins.listToAttrs (builtins.map (v: {
      name = "${builtins.toString (v.id - ID_OFFSET)}";
      value = {inherit (v) x y z;};
    })
    data.solarSystems);
in {
  imports = [../../default.nix];

  lantian.bgp-graph.eve = {
    baseAsn = 4200000000;
    baseCidr = "fdbc:f9dc:67ad:0e0e::/64";

    nodes =
      builtins.map (planet: {
        name = "${planet.region}-${planet.name}";
        id = planet.id - ID_OFFSET;
      })
      data.solarSystems;

    edges =
      builtins.map (jump: rec {
        fromId = jump.from - ID_OFFSET;
        toId = jump.to - ID_OFFSET;
        distance = let
          x = idToCoordinate."${builtins.toString fromId}".x;
          y = idToCoordinate."${builtins.toString fromId}".y;
          z = idToCoordinate."${builtins.toString fromId}".z;
          x' = idToCoordinate."${builtins.toString toId}".x;
          y' = idToCoordinate."${builtins.toString toId}".y;
          z' = idToCoordinate."${builtins.toString toId}".z;
        in
          builtins.ceil (DISTANCE_RATIO
            * LT.math.sqrt (
              (LT.math.pow (x - x') 2) + (LT.math.pow (y - y') 2) + (LT.math.pow (z - z') 2)
            ));
      })
      data.jumps;
  };
}
