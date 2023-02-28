{lib, ...}: let
  allowed =
    lib.lowerChars
    ++ lib.upperChars
    ++ lib.stringToCharacters ("0123456789" + "_");
in
  lib.stringAsChars (k:
    if builtins.elem k allowed
    then k
    else "_")
