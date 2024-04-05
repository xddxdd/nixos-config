{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  fonts.fontDir.enable = true;

  fonts.packages =
    with pkgs;
    lib.mkForce [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "FiraMono"
          "Noto"
          "Terminus"
          "Ubuntu"
          "UbuntuMono"
        ];
      })

      corefonts
      fira-code
      fira-code-symbols
      font-awesome
      kaixinsong-fonts
      hanazono
      hoyo-glyphs
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      noto-fonts-extra
      plangothic-fonts.allideo
      source-code-pro
      source-han-code-jp
      source-han-mono
      source-han-sans
      source-han-serif
      source-sans
      source-sans-pro
      source-serif
      source-serif-pro
      terminus_font_ttf
      ubuntu_font_family
      vistafonts
      vistafonts-chs
      vistafonts-cht
      wqy_microhei
      wqy_zenhei
    ];

  # https://keqingrong.cn/blog/2019-10-01-how-to-display-all-chinese-characters-on-the-computer/
  fonts.fontconfig =
    let
      sansFallback = [
        "Plangothic P1"
        "Plangothic P2"
        "HanaMinA"
        "HanaMinB"
      ];
      serifFallback = [
        "HanaMinA"
        "HanaMinB"
        "Plangothic P1"
        "Plangothic P2"
      ];
    in
    {
      defaultFonts = rec {
        emoji = [ "Blobmoji" ];
        serif = [
          "Noto Serif"
          "Source Han Serif SC"
        ] ++ emoji ++ serifFallback;
        sansSerif = [
          "Ubuntu"
          "Source Han Sans SC"
        ] ++ emoji ++ sansFallback;
        monospace = [
          "Ubuntu Mono"
          "Noto Sans Mono CJK SC"
        ] ++ emoji ++ sansFallback;
      };
    };
}
