{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  services.fluidsynth = {
    enable = true;
    soundFont = LT.constants.soundfontPath pkgs;
    soundService = "pipewire-pulse";
  };

  xdg.dataFile."soundfont.sf2".source = LT.constants.soundfontPath pkgs;
}
