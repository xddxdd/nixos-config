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
  programs.mercurial = {
    enable = true;
    package = pkgs.mercurialFull;
    inherit (config.programs.git) userName userEmail;
  };
}
