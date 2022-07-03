{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix { }) dialRule enumerateList prefixZeros;

  localNumbers = [
    "1000"
    "1001"
  ];
in
rec {
  localDevices = builtins.concatStringsSep "\n" (builtins.map
    (number: ''
      [${number}](template-local-devices)
      auth=${number}
      aors=${number}
      callerid=Lan Tian <${number}>

      [${number}](template-aor)
    '')
    localNumbers);

  destLocal = builtins.concatStringsSep "\n" (builtins.map
    (number: dialRule number [
      "Dial(PJSIP/${number})"
    ])
    localNumbers);
}
