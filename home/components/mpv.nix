{ config, pkgs, ... }:

{
  xdg.configFile."mpv/mpv.conf".text = ''
    input-ipc-server=/tmp/mpvsocket
    hwdec=auto-copy
    hwdec-codecs=all
    gpu-context=wayland
    hr-seek-framedrop=no
    no-resume-playback
  '';
}
