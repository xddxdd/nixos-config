{
  inputs,
  ...
}:
''
  export SECRET_BASE=${inputs.secrets}

  for S in $(find nixos/ -name update.\*) $(find home/ -name update.\*); do
    echo "Executing $S"
    chmod +x "$S"
    "$S"
  done
''
