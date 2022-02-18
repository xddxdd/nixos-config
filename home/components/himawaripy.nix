{ config, pkgs, ... }:

let
  himawaripy = pkgs.python3Packages.buildPythonPackage rec {
    pname = "himawaripy";
    version = "2.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "boramalper";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-GcHFB851ClQjFjqTMZbRuGdg4kWjAnou9w9l+UDYM5c=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      appdirs
      pillow
      dateutil
    ];

    meta = with pkgs.lib; {
      description = "Set near-realtime picture of Earth as your desktop background";
      homepage = "https://github.com/boramalper/himawaripy";
      license = with licenses; [ mit ];
    };
  };
in {
  systemd.user.services.himawaripy = {
    Service = {
      Type = "oneshot";
      ExecStart = "${himawaripy}/bin/himawaripy --auto-offset";
    };
  };

  systemd.user.timers.himawaripy = {
    Install = {
      WantedBy = [ "timers.target" ];
    };
    Timer = {
      OnCalendar = "*:0/10";
      Persistent = true;
      Unit = "himawaripy.service";
    };
  };
}
