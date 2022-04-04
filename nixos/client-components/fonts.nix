{ config, pkgs, lib, ... }:

{
  fonts.fonts = with pkgs; lib.mkForce [
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
    genshin-glyphs
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji-blob-bin
    noto-fonts-extra
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
    wqy_microhei
    wqy_zenhei
  ];

  fonts.fontconfig = {
    defaultFonts = {
      emoji = [ "Blobmoji" ];
      serif = [ "Noto Serif" "Source Han Serif SC" ];
      sansSerif = [ "Ubuntu" "Source Han Sans SC" ];
      monospace = [ "Ubuntu Mono" "Noto Sans Mono CJK SC" ];
    };
  };
}
