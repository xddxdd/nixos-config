{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  inherit (pkgs.callPackage ./common.nix args) dialRule prefixZeros;

  musics = [
    "nightglow.mp3"
    "rubia.mp3"
    "ye_hang_xing.mp3"
    "cage.mp3"
    "550w_moss.mp3"
    "lai_zi_tian_tang_de_mo_gui.mp3"
    "zen_me_hai_bu_ai.mp3"
    "chen_yi_xun_gu_yong_zhe.mp3"
    "zu_ya_na_xi_gu_yong_zhe.mp3"
    "xi_ju_xing_fan_feng.mp3"
    "qing_lian.mp3"
  ];

  musicSrc = pkgs.stdenvNoCC.mkDerivation {
    pname = "nixos-asterisk-music";
    version = "1.0";
    src = pkgs.fetchurl {
      url = "https://private.xuyh0120.win/nixos-asterisk-music.tar.zst";
      sha256 = "09ij277jd4pqcpgbhc6wkyvnzhwcgdpkv86vknyvlyq2x9915rph";
    };

    nativeBuildInputs = with pkgs; [ffmpeg zstd];

    installPhase = ''
      mkdir -p $out
      ls -alh
      for F in *; do
        ffmpeg -i $F \
          -ar 48000 -ac 1 -acodec pcm_s16le -f s16le \
          $out/$F.sln48
      done
    '';
  };
in rec {
  destLocalForwardMusic = digits: let
    randomForwardRule = dialRule "0000" [
      "Goto(dest-music,\${RAND(1,${builtins.toString (builtins.length musics)})},1)"
    ];

    individualRules =
      lib.genList
      (i:
        dialRule (prefixZeros digits (builtins.toString (i + 1))) [
          "Goto(dest-music,${builtins.toString (i + 1)},1)"
        ])
      (builtins.length musics);
  in
    builtins.concatStringsSep "\n" ([randomForwardRule] ++ individualRules);

  destMusic =
    lib.concatMapStringsSep "\n"
    ({
      index,
      value,
    }:
      dialRule (builtins.toString (index + 1)) [
        "Answer()"
        "Playback(${musicSrc}/${value})"
      ])
    (LT.enumerateList musics);
}
