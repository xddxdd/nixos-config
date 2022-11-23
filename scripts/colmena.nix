{ pkgs, inputs, ... }:

let
  inherit (inputs.colmena.packages."${pkgs.system}") colmena;
in
''
  ACTION=$1; shift;
  if [ "$ACTION" = "apply" ] || [ "$ACTION" = "build" ]; then
    ${colmena}/bin/colmena $ACTION --keep-result $*
    exit $?
  else
    ${colmena}/bin/colmena $ACTION $*
    exit $?
  fi
''
