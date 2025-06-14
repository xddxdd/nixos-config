{ config, lib, ... }:
let
  mkColor = color: {
    r = config.lib.stylix.colors."${color}-rgb-r";
    g = config.lib.stylix.colors."${color}-rgb-g";
    b = config.lib.stylix.colors."${color}-rgb-b";
  };
in
{
  stylix.targets = {
    # Having KDE is enough, QT module only supports qtct not kde6
    qt.enable = false;

    firefox = {
      colorTheme.enable = true;
      profileNames = [ "lantian" ];
    };
    librewolf = {
      colorTheme.enable = true;
      profileNames = [ "lantian" ];
    };
  };

  programs = lib.genAttrs [ "firefox" "librewolf" ] (n: {
    profiles.lantian.extensions.settings."FirefoxColor@mozilla.com".settings.theme.colors = {
      frame = lib.mkForce (mkColor "base00");
    };
  });
}
