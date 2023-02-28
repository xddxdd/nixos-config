{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: rec {
  dialRule = number: rules:
    builtins.foldl'
    (l: ll:
      l
      + ''
        same => n,${ll}
      '')
    ''
      exten => ${number},1,${builtins.head rules}
    ''
    ((builtins.tail rules) ++ ["Hangup()"]);

  enumerateList =
    builtins.foldl'
    (l: ll:
      l
      ++ [
        {
          index = builtins.length l;
          value = ll;
        }
      ])
    [];

  prefixZeros = length: s:
    if (builtins.stringLength s) < length
    then prefixZeros length ("0" + s)
    else s;
}
