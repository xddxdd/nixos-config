{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  home.packages = with pkgs; [
    discord
    element-desktop
    tdesktop
    thunderbird
  ];

  xdg.configFile = LT.autostart [
    ({ name = "discord"; command = "${pkgs.discord}/bin/discord --start-minimized"; })
    ({ name = "element"; command = "${pkgs.element-desktop}/bin/element-desktop --hidden"; })
    ({ name = "telegram"; command = "${pkgs.tdesktop}/bin/telegram-desktop -autostart"; })
    ({ name = "thunderbird"; command = "${pkgs.thunderbird}/bin/thunderbird"; })
    ({ name = "ulauncher"; command = "${pkgs.ulauncher}/bin/ulauncher --hide-window"; })
  ];
}
