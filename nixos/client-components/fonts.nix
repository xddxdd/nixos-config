{ pkgs, lib, ... }:
{
  fonts.fontDir.enable = true;
  fonts.packages =
    with pkgs;
    lib.mkForce [
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.noto
      nerd-fonts.terminess-ttf
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono

      corefonts
      fira-code
      fira-code-symbols
      font-awesome
      hanazono
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      nur-xddxdd.hoyo-glyphs
      nur-xddxdd.kaixinsong-fonts
      nur-xddxdd.plangothic-fonts
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
      ubuntu-classic
      vista-fonts
      vista-fonts-chs
      vista-fonts-cht
      wqy_microhei
      wqy_zenhei
    ];

  # https://keqingrong.cn/blog/2019-10-01-how-to-display-all-chinese-characters-on-the-computer/
  fonts.fontconfig = {
    cache32Bit = true;
    subpixel.rgba = "rgb";

    defaultFonts = {
      sansSerif = builtins.map lib.mkAfter [
        # Fix font aliasing with fallback fonts
        "Source Han Sans SC"
        # Cover large amounts of characters
        "Plangothic P1"
        "Plangothic P2"
        "HanaMinA"
        "HanaMinB"
      ];
      serif = builtins.map lib.mkAfter [
        # Fix font aliasing with fallback fonts
        "Source Han Serif SC"
        # Cover large amounts of characters
        "HanaMinA"
        "HanaMinB"
        "Plangothic P1"
        "Plangothic P2"
      ];
      monospace = builtins.map lib.mkAfter [
        # Fix font aliasing with fallback fonts
        "Noto Sans Mono CJK SC"
        # Cover large amounts of characters
        "Plangothic P1"
        "Plangothic P2"
        "HanaMinA"
        "HanaMinB"
      ];
    };
  };
}
