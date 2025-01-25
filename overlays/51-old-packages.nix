{ inputs, ... }:
final: _prev:
let
  pkgs-24-11 = inputs.nixpkgs-24-11.legacyPackages."${final.system}";
in
rec {
  inherit (pkgs-24-11) flaresolverr;
}
