{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  boot.extraModprobeConfig = let
    enableGucFlag =
      if config.virtualisation.kvmgt.enable
      then 0
      else if builtins.elem LT.tags.i915-sriov LT.this.tags
      then 7
      else 3;
  in ''
    options i915 enable_fbc=1 enable_guc=${builtins.toString enableGucFlag}
  '';

  boot.kernel.sysctl = {
    "dev.i915.perf_stream_paranoid" = 0;
  };

  environment.systemPackages = with pkgs; [
    clinfo
    libva-utils
    vdpauinfo
    intel-gpu-tools
  ];

  # Hardware
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    libinput.enable = true;
    libinput.touchpad = {
      horizontalScrolling = true;
      naturalScrolling = true;
      tapping = true;
      tappingDragLock = false;
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      (vaapiIntel.override {enableHybridCodec = true;}) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
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

    # Webkit2gtk fixes
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";
  };
}
