{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  boot.extraModprobeConfig =
    let
      enableGucFlag = if config.virtualisation.kvmgt.enable then 0 else 3;
    in
    ''
      options i915 enable_fbc=1 enable_guc=${builtins.toString enableGucFlag}
    '';

  boot.kernel.sysctl = {
    "dev.i915.perf_stream_paranoid" = 0;
  };

  environment.systemPackages = with pkgs; [
    clinfo
    libva-utils
    vdpauinfo
  ];

  # Hardware
  services.libinput = {
    enable = true;
    touchpad = {
      horizontalScrolling = true;
      naturalScrolling = true;
      tapping = true;
      tappingDragLock = false;
    };
  };

  services.xserver = {
    enable = true;
    exportConfiguration = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      (vaapiIntel.override { enableHybridCodec = true; }) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };

  hardware.intel-gpu-tools.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "lantian";
  };

  services.xserver.displayManager.lightdm.enable = false;

  environment.variables = {
    # SDL Soundfont
    SDL_SOUNDFONTS = LT.constants.soundfontPath pkgs;

    # Webkit2gtk fixes
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";

    # Default to Intel hardware decoding
    LIBVA_DRIVER_NAME = lib.mkDefault "iHD";
    VDPAU_DRIVER = lib.mkDefault "va_gl";
  };

  programs.xwayland.enable = true;
  users.users.lantian.extraGroups = [
    "video"
    "users"
    "input"
  ];

  xdg = {
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
