{ inputs, ... }:
final: prev:
let
  pkgs-stable = inputs.nixpkgs-stable.legacyPackages."${final.system}";
in
rec {
  # Bepasty doesn't build on nixos-unstable due to xstatic issue
  inherit (pkgs-stable) bepasty;
}
