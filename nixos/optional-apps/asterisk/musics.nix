{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  inherit (pkgs.callPackage ./common.nix args) dialRule enumerateList prefixZeros;

  musics = [
    "nightglow"
    "rubia"
    "ye_hang_xing"
    "cage"
    "550w_moss"
    "lai_zi_tian_tang_de_mo_gui"
    "zen_me_hai_bu_ai"
    "chen_yi_xun_gu_yong_zhe"
    "zu_ya_na_xi_gu_yong_zhe"
  ];

  getMusicPath = music:
    let
      converted = pkgs.stdenvNoCC.mkDerivation {
        pname = music;
        version = "1.0";
        src = inputs.nixos-asterisk-music + "/${music}.mp3";

        nativeBuildInputs = with pkgs; [ ffmpeg ];

        phases = [ "installPhase" ];
        installPhase = ''
          mkdir -p $out
          ffmpeg -i ${inputs.nixos-asterisk-music}/${music}.mp3 \
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

  destMusic = lib.concatMapStringsSep "\n"
    ({ index, value }: dialRule (builtins.toString (index + 1)) [
      "Answer()"
      "Playback(${getMusicPath value})"
    ])
    (enumerateList musics);
}
