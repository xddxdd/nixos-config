{ pkgs, inputs, ... }:
''
  ACTION=$1; shift;
  if [ "$ACTION" = "apply" ] || [ "$ACTION" = "build" ]; then
    ${pkgs.colmena}/bin/colmena $ACTION \
      --eval-node-limit 5 \
      --parallel 0 \
      --keep-result \
      --show-trace \
      $*
    exit $?
  else
    ${pkgs.colmena}/bin/colmena $ACTION $*
    exit $?
  fi
''
