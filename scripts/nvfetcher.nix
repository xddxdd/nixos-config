{
  nvfetcher,
  python3,
  python3Packages,
  ...
}: ''
  export PYTHONPATH=${python3Packages.packaging}/lib/python${python3.pythonVersion}/site-packages:''${PYTHONPATH:-}
  [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="-k $HOME/Secrets/nvfetcher.toml" || KEY_FLAG=""
  ${nvfetcher}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o helpers/_sources "$@"
''
