{ pkgs, ... }:

let
  publicPeers = pkgs.lib.importJSON ./public-peers.json;
in
regions: pkgs.lib.flatten (builtins.map (region: publicPeers."${region}") regions)
