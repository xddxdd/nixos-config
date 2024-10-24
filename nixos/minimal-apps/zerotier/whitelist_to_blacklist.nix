{ lib, ... }:
wl:
let
  allowed_chars = lib.stringToCharacters "1234567890abcdefghijklmnopqrstuvwxyz";

  helper =
    prefix:
    builtins.map (
      ch:
      let
        whitelisted = builtins.elem (prefix + ch) wl;
        prefixed = builtins.any (lib.hasPrefix (prefix + ch)) wl;
      in
      if whitelisted then
        [ ]
      else if prefixed then
        helper (prefix + ch)
      else
        [ (prefix + ch) ]
    ) allowed_chars;
in
lib.flatten (helper "")
