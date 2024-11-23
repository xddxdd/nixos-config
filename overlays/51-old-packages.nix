{ inputs, ... }:
final: _prev:
let
  pkgs-24-05 = inputs.nixpkgs-24-05.legacyPackages."${final.system}";
in
rec {
  inherit (pkgs-24-05) linux_rpi4;
}
