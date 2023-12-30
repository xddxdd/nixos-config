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
      hwdec = "auto-copy";
      hwdec-codecs = "all";
      gpu-context = "wayland";
      hr-seek-framedrop = false;
      no-resume-playback = true;
    };
  };

  xdg.configFile."mpv/scripts".source = LT.sources.mpv-sockets.src;
}
