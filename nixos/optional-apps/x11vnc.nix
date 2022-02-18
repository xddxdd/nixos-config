{ config, pkgs, ... }:

{
  systemd.services.x11vnc = {
    description = "X11VNC";
    wantedBy = [ "graphical.target" ];
    after = [ "display-manager.service" ];
    bindsTo = [ "display-manager.service" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
    };
    script = ''
      ${pkgs.x11vnc}/bin/x11vnc \
        -listen localhost \
        -forever \
        -nopw \
        -rfbport 5900 \
        -noxdamage \
        -noxfixes \
        -display :0 \
        -auth /run/sddm/*
    '';
  };
}
