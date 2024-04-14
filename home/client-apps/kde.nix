{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  xdg.dataFile = {
    "plasma/plasmoids/ink.chyk.plasmaDesktopLyrics".source = "${pkgs.plasma-desktop-lyrics.src}/plasmoid";
    "plasma/plasmoids/org.kde.panel.transparency.toggle".source =
      LT.sources.plasma-panel-transparency-toggle.src;
  };
}
