{ nvfetcher, ... }:
''
  nix flake update
  ${nvfetcher}/bin/nvfetcher -c nvfetcher.toml -o helpers/_sources
''
