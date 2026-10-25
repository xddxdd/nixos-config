{
  pkgs,
  lib,
  realtimeArgs,
  config,
  ...
}:
let
  # Change pipewire-rtprio.nix as well
  realtimeLimitUS = 5000000;
  cfg = config.services.pipewire;
  pipewireService = {
    restartTriggers = [ config.environment.etc.pipewire.source ];
  };
  userPipewireService = pipewireService // {
    serviceConfig = lib.mapAttrs (_: lib.mkOptionDefault) realtimeArgs;
  };
in
{
  imports = [
    ./pipewire-airplay.nix
    ./pipewire-latency-adjust.nix
    ./pipewire-rtprio.nix
    ./pipewire-surround.nix
    ./wireplumber-bluez.nix

    # Pipewire Zeroconf is not very stable
    # ./pipewire-zeroconf.nix
  ];

  # Enable OSS emulation
  boot.kernelModules = [ "snd_pcm_oss" ];

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  environment.systemPackages = [
    pkgs.crosspipe
    pkgs.pavucontrol
    pkgs.pulseaudio
  ];

  security.rtkit.enable = true;
  systemd.services.rtkit-daemon.serviceConfig.ExecStart = [
    "" # Override command in rtkit package's service file
    "${pkgs.rtkit}/libexec/rtkit-daemon --rttime-usec-max=${builtins.toString realtimeLimitUS}"
  ];

  services.pipewire = {
    enable = true;
    # Fix for ROC sink bug: https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/4070
    package = pkgs.pipewire.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../../../patches/pipewire-fix-roc-sink.patch ];
    });
    systemWide = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    wireplumber.enable = true;

    extraConfig.pipewire = {
      "10-sample-rate" = {
        "context.properties" = {
          "default.clock.rate" = 44100;
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
            192000
          ];

          # Fix stuttering
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 2048;
        };
      };
    };
  };

  systemd.services.pipewire-auto-start = lib.mkIf (cfg.enable && cfg.systemWide) {
    description = "Keep PipeWire running";
    after = [ "pipewire.socket" ];
    requires = [ "pipewire.socket" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.netcat-openbsd} -U /run/pipewire/pipewire-0";
      User = "pipewire";
      Group = "pipewire";
      Restart = "always";
      RestartSec = "3";
      # Connects to the pipewire control UNIX socket
      BindPaths = [ "/run/pipewire" ];
    };
  };
  lantian.harden.pipewire-auto-start.enable = lib.mkIf (cfg.enable && cfg.systemWide) true;

  lantian.harden.pipewire = lib.mkIf (cfg.enable && cfg.systemWide) {
    realtime = true;
  };
  lantian.harden.pipewire-pulse = lib.mkIf (cfg.enable && cfg.systemWide && cfg.pulse.enable) {
    realtime = true;
  };

  systemd.services.pipewire = lib.mkIf (cfg.enable && cfg.systemWide) pipewireService;
  systemd.services.pipewire-pulse = lib.mkIf (
    cfg.enable && cfg.systemWide && cfg.pulse.enable
  ) pipewireService;
  systemd.user.services.pipewire = lib.mkIf (cfg.enable && !cfg.systemWide) userPipewireService;
  systemd.user.services.pipewire-pulse = lib.mkIf (
    cfg.enable && !cfg.systemWide && cfg.pulse.enable
  ) userPipewireService;

  users.users.lantian.extraGroups = [
    "audio"
  ]
  ++ lib.optionals config.services.pipewire.systemWide [ "pipewire" ];
}
