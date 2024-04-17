{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  imports = [ inputs.nur-xddxdd.nixosModules.plasma-desktop-lyrics ];

  environment.systemPackages = with pkgs; [
    (material-kwin-decoration.overrideAttrs (old: {
      inherit (LT.sources.material-kwin-decoration) version src;
    }))
    plasma-panel-transparency-toggle
  ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasmawayland";

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
}
