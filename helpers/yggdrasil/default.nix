{ lib, ... }:

let
  publicPeers = lib.importJSON ./public-peers.json;
in
regions: lib.flatten (builtins.map (region: publicPeers."${region}") regions)
