_: rec {
  dialRule =
    number: rules:
    builtins.foldl'
      (
        l: ll:
        l
        + ''
          same => n,${ll}
        ''
      )
      ''
        exten => _${number},1,${builtins.head rules}
      ''
      ((builtins.tail rules) ++ [ "Hangup()" ]);

  prefixZeros =
    length: s: if (builtins.stringLength s) < length then prefixZeros length ("0" + s) else s;
}
