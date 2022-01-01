{ pkgs, dns, ... }:

with dns;
let
  hosts = import ../hosts.nix;
  common = import ./common.nix { inherit pkgs dns; };
in
builtins.map
  (f: import (./domains + "/${f}") { inherit pkgs dns common hosts; })
  (pkgs.lib.mapAttrsToList (k: v: k) (builtins.readDir ./domains))
