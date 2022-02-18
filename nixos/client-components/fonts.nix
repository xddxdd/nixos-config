{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; pkgs.lib.mkForce [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-extra
    noto-fonts-emoji-blob-bin
    fira-code
    fira-code-symbols
    ubuntu_font_family
    wqy_microhei
    wqy_zenhei
  ];

  fonts.fontconfig = {
    defaultFonts = {
      emoji = [ "Blobmoji" ];
      serif = [ "Ubuntu" "WenQuanYi Micro Hei" ];
      sansSerif = [ "Ubuntu" "WenQuanYi Micro Hei" ];
      monospace = [ "Ubuntu Mono" ];
    };
  };
}
