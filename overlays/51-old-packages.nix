{ inputs, ... }:

final: prev:
let
  pkgs-22-05 = inputs.nixpkgs-22-05.legacyPackages."${final.system}";
  pkgs-22-11 = inputs.nixpkgs-22-11.legacyPackages."${final.system}";
in
rec {
  # clisp: https://github.com/NixOS/nixpkgs/pull/205270
  inherit (pkgs-22-11) clisp;

  # plausible: crashes on oneprovider with latest erlang runtime
  plausible = prev.plausible.override { beamPackages = pkgs-22-05.beamPackages; };
}
