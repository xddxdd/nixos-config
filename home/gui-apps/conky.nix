{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  xdg.configFile = LT.autostart [
    ({ name = "conky"; command = "${pkgs.conky}/bin/conky -c /etc/conky/conky.conf"; })
  ];
}
