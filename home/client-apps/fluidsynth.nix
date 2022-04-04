{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  services.fluidsynth = {
    enable = true;
    soundFont = LT.constants.soundfontPath pkgs;
    soundService = "pipewire-pulse";
  };

  xdg.dataFile."soundfont.sf2".source = LT.constants.soundfontPath pkgs;
}
