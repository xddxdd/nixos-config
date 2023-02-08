{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  environment.systemPackages = with pkgs; [
    (material-kwin-decoration.overrideAttrs (old: {
      inherit (LT.sources.material-kwin-decoration) version src;
    }))
  ];

  services.xserver.desktopManager.plasma5 = {
    enable = true;
    # If enabled on wayland, app autostart don't reliably work
    runUsingSystemd = false;
  };
  services.xserver.displayManager.defaultSession = "plasmawayland";

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeter.enable = false;
  };

  programs.dconf.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  programs.seahorse.enable = true;
  programs.ssh.askPassword = "${pkgs.libsForQt5.ksshaskpass}/bin/ksshaskpass";
  programs.xwayland.enable = true;

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
