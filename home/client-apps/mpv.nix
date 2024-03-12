{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  osConfig,
  ...
} @ args: {
  programs.mpv = {
    enable = true;
    package = pkgs.svp-mpv;
    config =
      {
        cscale = "ewa_lanczossharp";
        gpu-context = "wayland";
        hr-seek-framedrop = false;
        hwdec = "auto-copy";
        hwdec-codecs = "all";
        no-resume-playback = "";
        scale = "ewa_lanczossharp";
      }
      // (lib.optionalAttrs (osConfig.networking.hostName == "lt-dell-wyse") {
        hwdec = "vaapi";
        scale = "lanczos";
        dither = false;
        correct-downscaling = false;
        linear-downscaling = false;
        sigmoid-upscaling = false;
        hdr-compute-peak = false;
        allow-delayed-peak-detect = true;
      });
  };

  xdg.configFile."mpv/scripts".source = LT.sources.mpv-sockets.src;
}
