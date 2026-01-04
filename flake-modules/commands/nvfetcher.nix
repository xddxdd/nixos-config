{
  lib,
  nvfetcher,
  python3,
  python3Packages,
  ...
}:
''
  export PYTHONPATH=${python3Packages.packaging}/${python3.sitePackages}:''${PYTHONPATH:-}
  [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="-k $HOME/Secrets/nvfetcher.toml" || KEY_FLAG=""
  ${lib.getExe nvfetcher} $KEY_FLAG -c nvfetcher.toml -o helpers/_sources "$@"
''
