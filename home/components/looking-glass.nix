{ config, pkgs, ... }:

{
  xdg.configFile."looking-glass/client.ini".text = pkgs.lib.generators.toINI { } {
    app.shmFile = "/dev/kvmfr0";
    input.escapeKey = 119;
    input.rawMouse = "yes";
    win.fullScreen = "yes";
    spice.enable = "no";
  };

  xdg.dataFile = {
    "applications/looking-glass.desktop".text = ''
      [Desktop Entry]
      Name=Looking Glass
      Comment=Looking Glass
      Exec=/usr/bin/looking-glass-client
      Icon=looking-glass
      Terminal=false
      Type=Application
      Encoding=UTF-8
      Categories=Game;Application;
    '';
    "icons/hicolor/128x128/apps/looking-glass.png".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/gnif/LookingGlass/master/resources/icon-128x128.png";
      sha256 = "1cfy1rqw3ahs47fzmqzpmgpkhzfhhgbxcg85rkq84n70hwnvv05a";
    };
  };
}
