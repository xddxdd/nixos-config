{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  fonts.fontDir.enable = true;
  fonts.packages =
    with pkgs;
    lib.mkForce (
      [
        nerd-fonts.fira-code
        nerd-fonts.fira-mono
        nerd-fonts.noto
        nerd-fonts.terminess-ttf
        nerd-fonts.ubuntu
        nerd-fonts.ubuntu-mono

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
        wqy_microhei
        wqy_zenhei
      ]
      ++ builtins.attrValues (
        lib.removeAttrs inputs.chinese-fonts-overlay.packages."${pkgs.stdenv.hostPlatform.system}" [
          "xiaomi-fonts"
        ]
      )
    );

  # https://keqingrong.cn/blog/2019-10-01-how-to-display-all-chinese-characters-on-the-computer/
  fonts.fontconfig = {
    aliases = {
      # Old Traditional Chinese software expects MingLiU/PMingLiU, which is not
      # installed; fall back to Noto Serif CJK TC (MingLiU is a serif face)
      MingLiU = {
        binding = "weak";
        accept = [ "Noto Serif CJK TC" ];
      };
      "細明體" = {
        binding = "weak";
        accept = [ "Noto Serif CJK TC" ];
      };
      PMingLiU = {
        binding = "weak";
        accept = [ "Noto Serif CJK TC" ];
      };
      "新細明體" = {
        binding = "weak";
        accept = [ "Noto Serif CJK TC" ];
      };
      # Vista renamed KaiTi_GB2312/FangSong_GB2312 to KaiTi/FangSong
      KaiTi_GB2312 = {
        binding = "weak";
        accept = [ "KaiTi" ];
      };
      "楷体_GB2312" = {
        binding = "weak";
        accept = [ "KaiTi" ];
      };
      FangSong_GB2312 = {
        binding = "weak";
        accept = [ "FangSong" ];
      };
      "仿宋_GB2312" = {
        binding = "weak";
        accept = [ "FangSong" ];
      };
      # Bitmap font dropped after XP
      "MS Sans Serif" = {
        binding = "weak";
        accept = [ "Tahoma" ];
      };
    };

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
