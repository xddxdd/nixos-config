{ pkgs, LT, ... }:
let
  looking-glass-client-override =
    pkgs.runCommand "looking-glass-client-override" { nativeBuildInputs = with pkgs; [ makeWrapper ]; }
      ''
        mkdir -p $out/bin $out/share/applications

        makeWrapper \
          ${pkgs.looking-glass-client}/bin/looking-glass-client \
          $out/bin/looking-glass-client \
          ${LT.constants.forceX11WrapperArgs}

        for F in ${pkgs.looking-glass-client}/share/applications/*; do
          sed "/Terminal=/d" < "$F" > $out/share/applications/$(basename "$F")
        done

        ln -sf ${pkgs.looking-glass-client}/share/pixmaps $out/share/pixmaps
      '';
in
{
  programs.looking-glass-client = {
    enable = true;
    package = looking-glass-client-override;
    settings = {
      app.shmFile = "/dev/kvmfr0";
      input.escapeKey = 119;
      input.rawMouse = "yes";
      spice.enable = "yes";
      win.autoScreensaver = "yes";
      win.fullScreen = "yes";
      win.jitRender = "yes";
      win.quickSplash = "yes";
    };
  };
}
