{ config, pkgs, lib, ... }:

{
  xdg.configFile."mpv/mpv.conf".text = ''
    hwdec=auto-copy
    hwdec-codecs=all
    #gpu-context=wayland
    hr-seek-framedrop=no
    no-resume-playback
  '';
}
