{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  environment.systemPackages = with pkgs; [
    (material-kwin-decoration.overrideAttrs (old: {
      inherit (LT.sources.material-kwin-decoration) version src;
    }))
  ];

  # services.xserver.desktopManager.plasma5 = {
  #   enable = true;
  #   runUsingSystemd = true;
  # };
  services.xserver.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.displayManager.lightdm.enable = false;

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd startplasma-wayland";
        user = "greeter";
      };
      initial_session = {
        command = "startplasma-wayland";
        user = "lantian";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    startplasma-wayland
  '';

  programs.dconf.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  programs.seahorse.enable = true;
  programs.ssh.askPassword = "${pkgs.libsForQt5.ksshaskpass}/bin/ksshaskpass";
  programs.xwayland.enable = true;

  users.users.lantian.extraGroups = ["video" "users" "input"];

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
