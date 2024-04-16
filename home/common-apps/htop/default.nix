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
  xdg.configFile = {
    "htop/htoprc".source = ./htoprc;
  };
}
