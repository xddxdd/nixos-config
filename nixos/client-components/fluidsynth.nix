{
  pkgs,
  lib,
  ...
}:
let
  soundfontPath = "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
in
{
  environment.variables = {
    # SDL Soundfont
    SDL_SOUNDFONTS = soundfontPath;
  };

  systemd.services.fluidsynth = {
    description = "FluidSynth Daemon";
    documentation = [ "man:fluidsynth(1)" ];
    bindsTo = [ "pipewire-pulse.service" ];
    after = [ "pipewire-pulse.service" ];
    wantedBy = [ "multi-user.target" ];

    environment.PULSE_SERVER = "unix:/run/pulse/native";

    serviceConfig = {
      # Needs /dev/snd/seq for ALSA sequencer MIDI input
      PrivateDevices = false;
      # -s inevitably binds the TCP shell server on 0.0.0.0:9800;
      # keep it inside the service's own network namespace
      PrivateNetwork = true;
      ExecStart = "${lib.getExe pkgs.fluidsynth} -a pulseaudio -si ${soundfontPath}";
      User = "lantian";
      Restart = "on-failure";
      RestartSec = 3;
      # chroot's tmpfs root is ephemeral; bind audio devices and the
      # system-wide pipewire-pulse UNIX socket through
      BindPaths = [
        "/dev/snd"
        "/run/pulse"
      ];
    };
  };
  lantian.harden.fluidsynth = {
    enable = true;
    realtime = true;
  };
}
