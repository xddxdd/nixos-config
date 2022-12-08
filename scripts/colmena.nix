{ pkgs, inputs, ... }:

''
  ACTION=$1; shift;
  if [ "$ACTION" = "apply" ] || [ "$ACTION" = "build" ]; then
    colmena $ACTION --keep-result $*
    exit $?
  else
    colmena $ACTION $*
    exit $?
  fi
''
