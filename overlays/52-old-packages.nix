{ inputs, ... }:
final: prev:
let
  pkgs-stable = inputs.nixpkgs-stable.legacyPackages."${final.system}";
in
rec {
  inherit (pkgs-stable) linphone;
}
