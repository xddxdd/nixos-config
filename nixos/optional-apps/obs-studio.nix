{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };
    plugins = with pkgs.obs-studio-plugins; [
      # keep-sorted start
      input-overlay
      looking-glass-obs
      obs-gstreamer
      obs-multi-rtmp
      obs-mute-filter
      obs-noise
      obs-vkcapture
      wlrobs
      # keep-sorted end
    ];
  };

  # Temporarily omit v4l2loopback: its modules.alias conflicts with the kernel module tree.

  users.users.lantian.extraGroups = [ "video" ];
}
