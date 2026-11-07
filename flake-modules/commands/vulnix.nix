{ lib, vulnix, ... }:
let
  whitelist = ../../vulnix-whitelist.toml;
in
''
  # -C limits the scan to the runtime closure; the default requisites walk also
  # pulls in build-time inputs that never run on the host.
  if [ $# -eq 0 ]; then set -- .gcroots/*; fi
  exec ${lib.getExe vulnix} -C -w ${whitelist} "$@"
''
