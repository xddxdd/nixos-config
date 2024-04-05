{
  pkgs,
  lib,
  LT,
  config,
  osConfig,
  utils,
  inputs,
  ...
}@args:
{
  xdg.dataFile = builtins.listToAttrs (
    lib.flatten (
      builtins.map
        (size: [
          # https://www.reddit.com/r/Genshin_Impact/comments/x73g4p/mikozilla_fireyae/
          {
            name = "icons/hicolor/${builtins.toString size}x${builtins.toString size}/apps/firefox.png";
            value.source =
              if size < 48 then
                LT.gui.resizeIcon size ../files/mikozilla-fireyae.png
              else
                LT.gui.resizeIcon size ../files/mikozilla-fireyae-petals.png;
          }
        ])
        [
          8
          10
          14
          16
          22
          24
          32
          36
          40
          48
          64
          72
          96
          128
          192
          256
          480
          512
        ]
    )
  );
}
