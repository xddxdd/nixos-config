{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  gtk = {
    enable = true;
    font = {
      package = pkgs.ubuntu_font_family;
      name = "Ubuntu";
      size = 10;
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
          sed -i "s/STMC_Common_15_Finger.cur/STMC_GenshinFurina_15_Finger(alternative).cur/g" PROJECT/STMC/*GenshinFurina*.inf
        '';
    });
    name = "STMCS-601-GenshinFurina";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
  };
}
