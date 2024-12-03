{
  inputs,
  callPackage,
  python3,
  ...
}:
let
  nvfetcherCmd = callPackage ./nvfetcher.nix { };
  py = python3.withPackages (p: with p; [ requests ]);
in
''
  nix flake update
  ${nvfetcherCmd}

  export SECRET_BASE=${inputs.secrets}

  for S in $(find . -name update.sh); do
    echo "Executing $S"
    bash "$S"
  done
  for S in $(find . -name update.py); do
    echo "Executing $S"
    ${py}/bin/python3 "$S"
  done
''
