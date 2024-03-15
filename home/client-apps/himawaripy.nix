{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  himawaripy = pkgs.python3Packages.buildPythonPackage rec {
    inherit (LT.sources.himawaripy) pname version src;

    propagatedBuildInputs = with pkgs.python3Packages; [
      appdirs
      pillow
      dateutil
    ];
  };
in
{
  systemd.user.services.himawaripy = lib.mkIf false {
    Service = {
      Type = "oneshot";
      ExecStart = "${himawaripy}/bin/himawaripy --auto-offset";
      Environment = "PATH=/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/bin";
    };
  };

  systemd.user.timers.himawaripy = lib.mkIf false {
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
