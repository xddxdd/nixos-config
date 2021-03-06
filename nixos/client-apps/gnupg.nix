{ config, pkgs, lib, ... }:

{
  programs.gnupg = {
    agent = {
      enable = true;
      pinentryFlavor = "qt";
      enableBrowserSocket = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
    };
    dirmngr.enable = true;
  };
}
