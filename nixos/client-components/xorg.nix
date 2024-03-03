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
      else 3;
    maxVfsFlag =
      if builtins.elem LT.tags.i915-sriov LT.this.tags
      then "max_vfs=7"
      else "";
  in ''
    options i915 enable_fbc=1 enable_guc=${builtins.toString enableGucFlag} ${maxVfsFlag}
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

  services.xserver.displayManager.lightdm.enable = false;

  environment.variables = {
    # Cursor fix
    # XCURSOR_SIZE = builtins.toString (builtins.floor (LT.constants.gui.cursorSize * config.lantian.hidpi));
    XCURSOR_SIZE = builtins.toString LT.constants.gui.cursorSize;

    # SDL Soundfont
    SDL_SOUNDFONTS = LT.constants.soundfontPath pkgs;

    # Webkit2gtk fixes
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";
  };

  programs.xwayland.enable = true;
  users.users.lantian.extraGroups = ["video" "users" "input"];

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
