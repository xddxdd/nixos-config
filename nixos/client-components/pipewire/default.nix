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

  environment.systemPackages = [
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

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    wireplumber.enable = true;
  };

  users.users.lantian.extraGroups = [ "audio" ];
}
