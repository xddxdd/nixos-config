{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.umbriel.nixosModules.default ];

  programs.umbriel.enable = true;
  services.displayManager.defaultSession = "umbriel";

  environment.systemPackages = [
    pkgs.nautilus
    pkgs.seahorse
  ];

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${lib.getExe' pkgs.greetd "agreety"} --cmd start-umbriel";
        user = "greeter";
      };
      initial_session = {
        command = "start-umbriel";
        user = "lantian";
      };
    };
  };

  systemd.services.greetd.serviceConfig.RestartSec = "5s";

  environment.etc."greetd/environments".text = ''
    start-umbriel
  '';

  security.polkit.enable = true;
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.upower = {
    enable = true;
    criticalPowerAction = "PowerOff";
  };

  programs.ssh.askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
}
