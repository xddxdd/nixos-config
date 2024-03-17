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
  programs.gnupg = {
    agent = {
      enable = true;
      enableBrowserSocket = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
    };
    dirmngr.enable = true;
  };
}
