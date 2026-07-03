{ lib, pkgs, ... }:
{
  programs.niri.enable = true;
  services.displayManager.defaultSession = "niri";

  environment.systemPackages = [
    # Used by shortcuts
    pkgs.brightnessctl
    pkgs.playerctl
    # Components usually available in desktop environment
    pkgs.nautilus
  ];
  services.udev.packages = [ pkgs.brightnessctl ];

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${lib.getExe' pkgs.greetd "agreety"} --cmd niri-session";
        user = "greeter";
      };
      initial_session = {
        command = "niri-session";
        user = "lantian";
      };
    };
  };
  environment.etc."greetd/environments".text = ''
    niri-session
  '';

  programs.dms-shell.enable = true;

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
}
