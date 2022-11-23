{ pkgs, lib, config, utils, inputs, ... }@args:

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
