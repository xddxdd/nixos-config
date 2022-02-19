{ config, pkgs, ... }:

let
  ulauncher = pkgs.ulauncher.overrideAttrs (old: {
    propagatedBuildInputs = with pkgs.python3Packages; old.propagatedBuildInputs ++  [
      fuzzywuzzy
      pint
      pytz
      simpleeval
    ];
  });
in
{
  environment.systemPackages = [ ulauncher ];

  systemd.user.services.ulauncher = {
    environment = {
      XDG_DATA_DIRS = "/run/current-system/sw/share";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "1";
      ExecStart = "${ulauncher}/bin/ulauncher --hide-window -v";
    };
    wantedBy = [ "graphical-session.target" ];
  };

  # Fix ulauncher startup error
  environment.pathsToLink = [ "/share/ulauncher" ];
}
