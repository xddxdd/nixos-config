{
  pkgs,
  lib,
  LT,
  ...
}@args:
let
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

    nativeBuildInputs = with pkgs; [
      zstd
    ];

    installPhase = ''
      mkdir -p $out
      cp * $out/
    '';
  };
in
rec {
  destLocalForwardMusic =
    digits:
    let
      randomForwardRule = dialRule "0000" [
        "Goto(dest-music,\${RAND(1,${builtins.toString (builtins.length musics)})},1)"
      ];

      individualRules = lib.genList (
        i:
        dialRule (prefixZeros digits (builtins.toString (i + 1))) [
          "Goto(dest-music,${builtins.toString (i + 1)},1)"
        ]
      ) (builtins.length musics);
    in
    builtins.concatStringsSep "\n" ([ randomForwardRule ] ++ individualRules);

  destMusic = lib.concatMapStringsSep "\n" (
    { index, value }:
    dialRule (builtins.toString (index + 1)) [
      "Answer()"
      "MP3Player(${musicSrc}/${value})"
    ]
  ) (LT.enumerateList musics);
}
