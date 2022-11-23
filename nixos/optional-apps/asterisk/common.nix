{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;
in
rec {
  dialRule = number: rules: builtins.foldl'
    (l: ll: l + ''
      same => n,${ll}
    '')
    ''
      exten => ${number},1,${builtins.head rules}
    ''
    ((builtins.tail rules) ++ [ "Hangup()" ]);

  enumerateList = builtins.foldl'
    (l: ll: l ++ [{
      index = builtins.length l;
      value = ll;
    }])
    [ ];

  prefixZeros = length: s:
    if (builtins.stringLength s) < length
    then prefixZeros length ("0" + s)
    else s;
}
