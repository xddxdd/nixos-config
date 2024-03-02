{
  nvfetcher,
  nvchecker,
  nix-prefetch-scripts,
  ...
}: ''
  export PATH=${nvchecker}/bin:${nix-prefetch-scripts}/bin:$PATH
  [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="-k $HOME/Secrets/nvfetcher.toml" || KEY_FLAG=""
  ${nvfetcher}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o helpers/_sources "$@"
''
