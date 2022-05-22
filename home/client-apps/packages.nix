{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  home.packages = with pkgs; [
    discord
    element-desktop
    gcdemu
    tdesktop
    thunderbird-wayland
    ulauncher
  ];

  xdg.configFile = LT.autostart [
    ({ name = "discord"; command = "${pkgs.discord}/bin/discord --start-minimized"; })
    ({ name = "element"; command = "${pkgs.element-desktop}/bin/element-desktop --hidden"; })
    ({ name = "gcdemu"; command = "${pkgs.gcdemu}/bin/gcdemu"; })
    ({ name = "telegram"; command = "${pkgs.tdesktop}/bin/telegram-desktop -autostart"; })
    ({ name = "thunderbird"; command = "${pkgs.thunderbird-wayland}/bin/thunderbird"; })
    ({ name = "ulauncher"; command = "${pkgs.ulauncher}/bin/ulauncher --hide-window"; })
  ];
}
