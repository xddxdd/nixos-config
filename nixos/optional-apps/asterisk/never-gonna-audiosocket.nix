{
  pkgs,
  lib,
  LT,
  ...
}:
{
  systemd.sockets.asterisk-never-gonna = {
    description = "Never Gonna AudioSocket server socket";
    wantedBy = [ "asterisk.service" ];
    socketConfig = {
      ListenStream = "127.0.0.1:${LT.portStr.Asterisk.AudioSocket}";
      Accept = true;
    };
  };

  systemd.services."asterisk-never-gonna@" = {
    description = "Never Gonna AudioSocket server (call %i)";
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.never-gonna} --audiosocket";
      StandardInput = "socket";
      StandardOutput = "socket";
      StandardError = "journal";
      User = "asterisk";
      Group = "asterisk";
    };
  };
}
