{ callPackage, ... }:
let
  nvfetcherCmd = callPackage ./nvfetcher.nix { };
in
''
  nix flake update
  ${nvfetcherCmd}
''
