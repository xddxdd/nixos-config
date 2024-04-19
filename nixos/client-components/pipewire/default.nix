{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
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
    ./pipewire-zeroconf.nix
    ./wireplumber-bluez.nix
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
    systemWide = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    wireplumber.enable = true;
  };

  users.users.lantian.extraGroups =
    [ "audio" ] ++ lib.optionals config.services.pipewire.systemWide [ "pipewire" ];
}
