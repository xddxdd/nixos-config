{ config, pkgs, lib, ... }:

{
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.enable = true;

  services.xserver.displayManager.sddm.settings = {
    Theme = {
      Current = "breeze";
      CursorTheme = "breeze_cursors";
      Font = "Ubuntu,10,-1,5,50,0,0,0,0,0";
    };

    Users = {
      MaximumUid = 60513;
      MinimumUid = 1000;
    };
  };

  programs.dconf.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  programs.seahorse.enable = true;
  programs.ssh.askPassword = "${pkgs.libsForQt5.ksshaskpass}/bin/ksshaskpass";

  users.users.lantian.extraGroups = [ "video" "users" "input" ];

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };
}
