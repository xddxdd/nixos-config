{
  pkgs,
  LT,
  inputs,
  ...
}:
{
  imports = [ inputs.nur-xddxdd.nixosModules.lyrica ];

  environment.systemPackages = with pkgs; [
    (material-kwin-decoration.overrideAttrs (_old: {
      inherit (LT.sources.material-kwin-decoration) version src;
    }))
    nur-xddxdd.plasma-panel-transparency-toggle

    nur-xddxdd.plasma-smart-video-wallpaper-reborn
    kdePackages.qtmultimedia # Dependencies for plasma-smart-video-wallpaper-reborn plugin

    # nur-xddxdd.plasma-yesplaymusic-lyric

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
  programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  programs.lyrica.package = pkgs.nur-xddxdd.lyrica-plasmoid;
}
