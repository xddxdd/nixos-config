{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix { }) dialRule enumerateList prefixZeros;

  localNumbers = [
    "1000"  # Laptop (Linphone)
    "1001"  # Phone (Linphone)
    "1002"  # Bria
    "1003"  # Reserved
    "1004"  # Reserved
  ];
in
rec {
  localDevices = builtins.concatStringsSep "\n" (builtins.map
    (number: ''
      [${number}](template-endpoint-common,template-endpoint-local)
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
