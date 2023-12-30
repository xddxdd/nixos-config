{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  programs.mpv = {
    enable = true;
    package = pkgs.svp-mpv;
    config = {
      cscale = "ewa_lanczossharp";
      gpu-context = "wayland";
      hr-seek-framedrop = false;
      hwdec = "auto-copy";
      hwdec-codecs = "all";
      no-resume-playback = true;
      scale = "ewa_lanczossharp";
    };
  };

  xdg.configFile."mpv/scripts".source = LT.sources.mpv-sockets.src;
}
