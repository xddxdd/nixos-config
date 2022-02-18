{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ ulauncher ];

  systemd.user.services.ulauncher = {
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = "1";
      ExecStart = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
