{
  callPackage,
  lib,
  rsync,
  ...
}:
let
  constants = callPackage ../helpers/constants.nix { };
  inherit (constants) asteriskMusics;
  files = lib.escapeShellArgs (builtins.map (n: "/home/lantian/Music/CloudMusic/" + n) asteriskMusics);
in
''
  TARGET_HOST=$1
  if [ -z "$1" ]; then
    echo "Usage: $0 target-host"
    exit 1
  fi

  ${rsync}/bin/rsync -avzrP \
    --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r \
    ${files} \
    ''${TARGET_HOST}.lantian.pub:/var/lib/asterisk-music/
''
