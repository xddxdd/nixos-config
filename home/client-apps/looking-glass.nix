{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  looking-glass-client-override =
    lib.hiPrio
    (pkgs.runCommand
      "looking-glass-client-override"
      {
        nativeBuildInputs = with pkgs; [makeWrapper];
      }
      ''
        mkdir -p $out/bin $out/share/applications

        makeWrapper \
          ${pkgs.looking-glass-client}/bin/looking-glass-client \
          $out/bin/looking-glass-client \
          --unset WAYLAND_DISPLAY

        for F in ${pkgs.looking-glass-client}/share/applications/*; do
          sed "/Terminal=/d" < "$F" > $out/share/applications/$(basename "$F")
        done
      '');
in {
  home.packages = with pkgs; [
    looking-glass-client
    looking-glass-client-override
  ];

  xdg.configFile."looking-glass/client.ini".text = lib.generators.toINI {} {
    app.shmFile = "/dev/kvmfr0";
    input.escapeKey = 119;
    input.rawMouse = "yes";
    spice.enable = "yes";
    win.autoScreensaver = "yes";
    win.fullScreen = "yes";
    win.jitRender = "yes";
    win.quickSplash = "yes";
  };
}
