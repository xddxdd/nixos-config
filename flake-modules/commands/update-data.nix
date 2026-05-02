{
  callPackage,
  ...
}:
let
  nvfetcherCmd = callPackage ./nvfetcher.nix { };
in
''
  nix flake update firefox-addons llm-agents nix-index-database secrets
  ${nvfetcherCmd}

  for S in $(find nixos/ -name update.\*) $(find home/ -name update.\*) $(find pkgs/ -name update.\*); do
    echo "Executing $S"
    chmod +x "$S"
    "$S"
  done
''
