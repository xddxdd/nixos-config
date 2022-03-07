{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; pkgs.lib.mkForce [
    (nerdfonts.override { fonts = [ "FiraCode" "UbuntuMono" ]; })
    fira-code
    fira-code-symbols
    font-awesome
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji-blob-bin
    noto-fonts-extra
    source-han-mono
    source-han-sans
    source-han-serif
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
