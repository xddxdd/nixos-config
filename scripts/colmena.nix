{
  pkgs,
  inputs,
  ...
}: ''
  ACTION=$1; shift;
  if [ "$ACTION" = "apply" ] || [ "$ACTION" = "build" ]; then
    colmena $ACTION --keep-result --show-trace --evaluator streaming $*
    exit $?
  else
    colmena $ACTION $*
    exit $?
  fi
''
