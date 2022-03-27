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
    "applications/looking-glass-client.desktop".text = ''
      [Desktop Entry]
      Name=Looking Glass
      Comment=Looking Glass
      Exec=${pkgs.looking-glass-client}/bin/looking-glass-client
      Icon=lg-logo
      Terminal=false
      Type=Application
      Encoding=UTF-8
      Categories=Game;Application;
    '';
  };
}
