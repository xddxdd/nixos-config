{
  inputs,
  python3,
  ...
}:
let
  py = python3.withPackages (
    p: with p; [
      requests
      beautifulsoup4
    ]
  );
in
''
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
