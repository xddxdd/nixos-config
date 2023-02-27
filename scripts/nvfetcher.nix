{ nvfetcher, ... }:
''
  [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="-k $HOME/Secrets/nvfetcher.toml" || KEY_FLAG=""
  ${nvfetcher}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o helpers/_sources "$@"
''
