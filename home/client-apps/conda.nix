{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  home.file.".condarc".text = builtins.toJSON {
    channels = [ "conda-forge" "defaults" ];
    channel_priority = "strict";
  };
}
