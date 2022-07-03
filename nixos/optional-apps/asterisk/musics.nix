{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix {}) dialRule enumerateList prefixZeros;

  musics = [
    "nightglow"
    "rubia"
    "ye_hang_xing"
  ];
in
rec {
  destLocalForwardMusic = digits:
    let
      randomForwardRule = dialRule "0000" [
        "Goto(dest-music,\${RAND(1,${builtins.toString (builtins.length musics)})},1)"
      ];

      individualRules = lib.genList
        (i: dialRule (prefixZeros digits (builtins.toString (i + 1))) [
          "Goto(dest-music,${builtins.toString (i + 1)},1)"
        ])
        (builtins.length musics);
    in
    builtins.concatStringsSep "\n" ([ randomForwardRule ] ++ individualRules);

  destMusic = builtins.concatStringsSep "\n"
    (builtins.map
      ({ index, value }: dialRule (builtins.toString (index + 1)) [
        "Answer()"
        "Playback(${pkgs.flake.nixos-asterisk-music}/${value})"
      ])
      (enumerateList musics));
}
