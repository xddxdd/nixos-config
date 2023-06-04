{
  config,
  pkgs,
  lib,
  ...
}:
builtins.foldl'
(l: ll:
    l
    ++ [
      {
        index = builtins.length l;
        value = ll;
      }
    ])
[]
