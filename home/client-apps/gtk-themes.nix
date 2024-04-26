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
  gtk = {
    enable = true;
    font = {
      package = pkgs.ubuntu_font_family;
      name = "Ubuntu";
      size = LT.constants.gui.fontSize;
    };
    iconTheme = {
      package = pkgs.breeze-icons;
      name = "breeze-dark";
    };
    theme = {
      package = pkgs.breeze-gtk;
      name = "Breeze-Dark";
    };
  };

  home.pointerCursor = {
    package = pkgs.sam-toki-mouse-cursors.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          sed -i "s/STMC_Common_13_Hand.cur/STMC_GenshinFurina_13_Hand(alternative).cur/g" PROJECT/STMC/*GenshinFurina*.inf
          sed -i "s/STMC_Common_15_Finger.cur/STMC_GenshinFurina_15_Finger(alternative).cur/g" PROJECT/STMC/*GenshinFurina*.inf
        '';
    });
    name = "STMCS-601-GenshinFurina";
    # size = builtins.floor (LT.constants.gui.cursorSize * osConfig.config.lantian.hidpi);
    size = LT.constants.gui.cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
  };
}
