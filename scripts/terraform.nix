{
  pkgs,
  lib,
  inputs,
  packages,
  age,
  ...
} @ args: ''
  set -euo pipefail

  if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
  nix build .#terraform-config
  cat result > config.tf.json

  TEMP_FILE=$(mktemp)
  ${age}/bin/age \
    -i "$HOME/.ssh/id_ed25519" \
    --decrypt -o "$TEMP_FILE" \
    "${inputs.secrets}/terraform.age"
  source "$TEMP_FILE"
  rm -f "$TEMP_FILE"

  exec ${packages.terraform-with-plugins}/bin/terraform "$@"
''
