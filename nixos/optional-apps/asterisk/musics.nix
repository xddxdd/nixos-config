{
  pkgs,
  lib,
  LT,
  ...
}@args:
let
  inherit (pkgs.callPackage ./common.nix args) dialRule prefixZeros;
in
rec {
  destLocalForwardMusic =
    digits:
    let
      randomForwardRule = dialRule "0000" [
        "Goto(dest-music,\${RAND(1,${builtins.toString (builtins.length LT.constants.asteriskMusics)})},1)"
      ];

      individualRules = lib.genList (
        i:
        dialRule (prefixZeros digits (builtins.toString (i + 1))) [
          "Goto(dest-music,${builtins.toString (i + 1)},1)"
        ]
      ) (builtins.length LT.constants.asteriskMusics);
    in
    builtins.concatStringsSep "\n" ([ randomForwardRule ] ++ individualRules);

  destMusic = lib.concatStringsSep "\n" (
    lib.imap1 (
      index: value:
      dialRule (builtins.toString index) [
        "Answer()"
        "MP3Player(/var/lib/asterisk-music/${lib.escape [ ";" ] value})"
      ]
    ) LT.constants.asteriskMusics
  );

  destMusicDialPlan = lib.mergeAttrsList (
    lib.imap1 (index: value: {
      "${prefixZeros 4 (builtins.toString index)}" = "Music playback: \"${value}\"";
    }) LT.constants.asteriskMusics
  );
}
