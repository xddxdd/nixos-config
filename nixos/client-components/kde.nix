{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  environment.systemPackages = with pkgs; [
    (material-kwin-decoration.overrideAttrs (old: {
      inherit (LT.sources.material-kwin-decoration) version src;
    }))
  ];

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
      gtkUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
