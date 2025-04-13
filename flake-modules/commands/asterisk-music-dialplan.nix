{
  callPackage,
  lib,
  ...
}:
let
  constants = callPackage ../../helpers/constants.nix { };
  inherit (constants) asteriskMusics;

  prefixZeros =
    length: s: if (builtins.stringLength s) < length then prefixZeros length ("0" + s) else s;
in
lib.concatStringsSep "\n" (
  lib.imap1 (index: value: ''
    echo "${prefixZeros 4 (builtins.toString index)}: ${value}"
  '') asteriskMusics
)
