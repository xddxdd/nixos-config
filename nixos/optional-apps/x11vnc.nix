{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  systemd.services.x11vnc = {
    description = "X11VNC";
    wantedBy = ["graphical.target"];
    after = ["display-manager.service"];
    bindsTo = ["display-manager.service"];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
    };
    script = ''
      exec ${pkgs.x11vnc}/bin/x11vnc \
        -listen ${LT.this.ltnet.IPv4} \
        -6 -listen6 ${LT.this.ltnet.IPv6} \
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
