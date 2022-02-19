{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

  himawaripy = pkgs.python3Packages.buildPythonPackage rec {
    inherit (LT.sources.himawaripy) pname version src;

    propagatedBuildInputs = with pkgs.python3Packages; [
      appdirs
      pillow
      dateutil
    ];
  };
in {
  systemd.user.services.himawaripy = {
    Service = {
      Type = "oneshot";
      ExecStart = "${himawaripy}/bin/himawaripy --auto-offset";
      Environment = "PATH=/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/bin";
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
