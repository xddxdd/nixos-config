{
  pkgs,
  lib,
  LT,
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

    serviceConfig = LT.serviceHarden // {
      # Needs /dev/snd/seq for ALSA sequencer MIDI input
      PrivateDevices = false;
      ExecStart = "${lib.getExe pkgs.fluidsynth} -a pulseaudio -si ${soundfontPath}";
      User = "lantian";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
