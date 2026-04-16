{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.nur-xddxdd.nixosModules.lyrica ];

  environment.systemPackages = with pkgs; [
    nur-xddxdd.plasma-panel-transparency-toggle

    nur-xddxdd.plasma-smart-video-wallpaper-reborn
    kdePackages.qtmultimedia # Dependencies for plasma-smart-video-wallpaper-reborn plugin

    kdePackages.wallpaper-engine-plugin

    nur-xddxdd.red-star-os-wallpapers
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    khelpcenter
    konsole
  ];

  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };
  services.displayManager.defaultSession = "plasmawayland";

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${lib.getExe' pkgs.greetd "agreety"} --cmd startplasma-wayland";
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

  programs.ssh.askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;

  programs.lyrica.package = pkgs.nur-xddxdd.lyrica-plasmoid;
}
