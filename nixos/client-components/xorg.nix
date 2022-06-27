{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  boot.extraModprobeConfig = ''
    options i915 enable_fbc=1 ${lib.optionalString (!config.virtualisation.kvmgt.enable) "enable_guc=3"}
  '';

  environment.systemPackages = with pkgs; [
    clinfo
    libva-utils
    vdpauinfo
    intel-gpu-tools
  ];

  # Hardware
  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad = {
    horizontalScrolling = true;
    naturalScrolling = true;
    tapping = true;
    tappingDragLock = false;
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      (vaapiIntel.override { enableHybridCodec = true; }) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "lantian";
  };

  environment.variables = {
    # Firefox fixes
    MOZ_X11_EGL = "1";
    MOZ_USE_XINPUT2 = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";

    # SDL Soundfont
    SDL_SOUNDFONTS = LT.constants.soundfontPath pkgs;
  };
}
