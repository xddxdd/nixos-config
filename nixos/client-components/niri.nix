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
    pkgs.xwayland-satellite
    # DMS plugin requirements
    pkgs.kdePackages.qtwebsockets
  ];
  services.udev.packages = [ pkgs.brightnessctl ];

  security.wrappers.brightnessctl = {
    source = pkgs.brightnessctl + "/bin/brightnessctl";
    owner = "root";
    group = "root";
    setuid = true;
    setgid = true;
  };

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
