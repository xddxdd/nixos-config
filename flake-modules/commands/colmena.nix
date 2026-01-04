{ lib, pkgs, ... }:
''
  ACTION=$1; shift;
  if [ "$ACTION" = "apply" ] || [ "$ACTION" = "build" ]; then
    ${lib.getExe pkgs.colmena} $ACTION \
      --eval-node-limit 5 \
      --parallel 0 \
      --keep-result \
      --show-trace \
      $*
    exit $?
  else
    ${lib.getExe pkgs.colmena} $ACTION $*
    exit $?
  fi
''
