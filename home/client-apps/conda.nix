{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  home.file.".condarc".text = builtins.toJSON {
    channels = [ "conda-forge" "defaults" ];
    channel_priority = "strict";
  };
}
