{ pkgs, lib, config, utils, inputs, ... }@args:

{
  home.packages = with pkgs; [ looking-glass-client ];

  xdg.configFile."looking-glass/client.ini".text = lib.generators.toINI { } {
    app.shmFile = "/dev/kvmfr0";
    input.escapeKey = 119;
    input.rawMouse = "yes";
    win.fullScreen = "yes";
    spice.enable = "no";
  };
}
