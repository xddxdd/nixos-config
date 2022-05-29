{ config, pkgs, lib, utils, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

  secondsToFrames = secs: secs * 1000 / 90;
in
{
  systemd.sockets.nyancat = {
    description = "Nyancat";
    listenStreams = [ "23" ];
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      Accept = true;
      MaxConnections = 8;
      MaxConnectionsPerSource = 2;
    };
  };

  systemd.services."nyancat@" = {
    description = "Nyancat";
    serviceConfig = LT.serviceHarden // {
      User = "nobody";
      Group = "nobody";
      ExecStart = "-${pkgs.nyancat}/bin/nyancat -t -f ${builtins.toString (secondsToFrames 60)}";
      StandardInput = "socket";
      StandardOutput = "socket";
    };
  };
}
