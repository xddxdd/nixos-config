{ inputs, lib, ... }:

final: prev:
rec {
  inherit (inputs.nixpkgs-22-05.legacyPackages."${final.system}")
    bees plausible yggdrasil;
}
