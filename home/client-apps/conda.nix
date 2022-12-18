{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  home.file.".condarc".text = builtins.toJSON {
    channels = [ "conda-forge" "defaults" ];
    channel_priority = "strict";
  };
}
