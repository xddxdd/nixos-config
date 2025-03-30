{
  pkgs,
  lib,
  LT,
  ...
}:
{
  services.fluidsynth = {
    enable = true;
    soundFont = LT.constants.soundfontPath pkgs;
    soundService = "pipewire-pulse";
  };

  systemd.user.services.fluidsynth.Unit.BindsTo = lib.mkForce [ ];

  xdg.dataFile."soundfont.sf2".source = LT.constants.soundfontPath pkgs;
}
