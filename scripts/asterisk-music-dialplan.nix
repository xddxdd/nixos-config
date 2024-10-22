{
  callPackage,
  lib,
  ...
}:
let
  constants = callPackage ../helpers/constants.nix { };
  enumerateList = callPackage ../helpers/fn/enumerate-list.nix { };
  inherit (constants) asteriskMusics;

  prefixZeros =
    length: s: if (builtins.stringLength s) < length then prefixZeros length ("0" + s) else s;
in
lib.concatMapStringsSep "\n" (
  { index, value }:
  ''
    echo "${prefixZeros 4 (builtins.toString (index + 1))}: ${value}"
  ''
) (enumerateList asteriskMusics)
