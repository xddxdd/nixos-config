{
  callPackage,
  lib,
  pkgs,
  rsync,
  ...
}:
let
  constants = callPackage ../../helpers/constants.nix { };
  inherit (constants) asteriskMusics;
  files = pkgs.writeText "files.txt" (builtins.concatStringsSep "\n" asteriskMusics);
in
''
  TARGET_HOST=$1
  if [ -z "$1" ]; then
    echo "Usage: $0 target-host"
    exit 1
  fi

  ${lib.getExe rsync} -avzrP \
    --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r \
    --include-from=${files} \
    --exclude=* \
    --delete-excluded \
    /home/lantian/Music/CloudMusic/常听/ \
    ''${TARGET_HOST}.lantian.pub:/var/lib/asterisk-music/
''
