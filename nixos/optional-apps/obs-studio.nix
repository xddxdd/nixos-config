{ pkgs, config, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      # keep-sorted start
      input-overlay
      looking-glass-obs
      obs-dvd-screensaver
      obs-gstreamer
      obs-multi-rtmp
      obs-mute-filter
      obs-noise
      obs-vkcapture
      wlrobs
      # keep-sorted end
    ];
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  # Don't autoload as it conflicts with physical camera on some programs
  # boot.kernelModules = [ "v4l2loopback" ];

  users.users.lantian.extraGroups = [ "video" ];
}
