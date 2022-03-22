{ config, pkgs, ... }:

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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    media-session.enable = false;
    wireplumber.enable = true;
  };

  users.users.lantian.extraGroups = [ "video" "audio" "users" "input" ];

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
