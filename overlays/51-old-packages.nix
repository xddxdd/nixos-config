{ inputs, ... }:

final: prev:
rec {
  inherit (inputs.nixpkgs-22-05.legacyPackages."${final.system}")
    plausible;

  # clisp: https://github.com/NixOS/nixpkgs/pull/205270
  inherit (inputs.nixpkgs-22-11.legacyPackages."${final.system}")
    clisp;
}
