{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  # Change pipewire-rtprio.nix as well
  realtimeLimitUS = 5000000;
in
{
  imports = [
    ./pipewire-airplay.nix
    ./pipewire-noise-cancelling.nix
    ./pipewire-resample-quality.nix
    ./pipewire-rtprio.nix
    ./pipewire-surround.nix
    ./wireplumber-bluez.nix

    # Pipewire Zeroconf is not very stable
    # ./pipewire-zeroconf.nix
  ];

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  environment.systemPackages = [
    pkgs.pavucontrol
    pkgs.pulseaudio
    pkgs.helvum
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
  };

  systemd.services.pipewire-auto-start = {
    description = "Keep PipeWire running";
    after = [ "pipewire.socket" ];
    requires = [ "pipewire.socket" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${pkgs.netcat-openbsd}/bin/nc -U /run/pipewire/pipewire-0";
      User = "pipewire";
      Group = "pipewire";
      Restart = "always";
      RestartSec = "3";
    };
  };

  users.users.lantian.extraGroups = [
    "audio"
  ] ++ lib.optionals config.services.pipewire.systemWide [ "pipewire" ];
}
