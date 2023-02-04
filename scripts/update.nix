{ nvfetcher, ... }:
let
  nvfetcherCmd = import ./nvfetcher.nix { inherit nvfetcher; };
in
''
  nix flake update
  ${nvfetcherCmd}
''
