_: ''
  nix flake update firefox-addons nix-index-database secrets

  for S in $(find nixos/ -name update.\*) $(find home/ -name update.\*) $(find pkgs/ -name update.\*); do
    echo "Executing $S"
    chmod +x "$S"
    "$S"
  done
''
