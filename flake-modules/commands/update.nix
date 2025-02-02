{
  inputs,
  callPackage,
  ...
}:
let
  nvfetcherCmd = callPackage ./nvfetcher.nix { };
  updateData = callPackage ./update-data.nix { inherit inputs; };
in
''
  nix flake update
  ${nvfetcherCmd}
  ${updateData}
''
