{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix { }) dialRule enumerateList prefixZeros;

  musics = [
    "nightglow"
    "rubia"
    "ye_hang_xing"
  ];

  getMusicPath = music:
    let
      converted = pkgs.stdenvNoCC.mkDerivation {
        pname = music;
        version = "1.0";
        src = pkgs.flake.nixos-asterisk-music + "/${music}.mp3";

        nativeBuildInputs = with pkgs; [ ffmpeg ];

        phases = [ "installPhase" ];
        installPhase = ''
          mkdir -p $out
          ffmpeg -i ${pkgs.flake.nixos-asterisk-music}/${music}.mp3 \
            -ar 48000 -ac 1 -acodec pcm_s16le -f s16le \
            $out/${music}.sln48
        '';
      };
    in
    "${converted}/${music}";
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
        "Playback(${getMusicPath value})"
      ])
      (enumerateList musics));
}
