{ pkgs,
  lib, LT, ... }:
let
  py = pkgs.python3.withPackages (
    p: with p; [
      requests
      pydantic
    ]
  );
in
{
  systemd.services.qbittorrent-pt-cleanup = {
    environment = {
      QBITTORRENT_URL = "http://127.0.0.1:${LT.portStr.qBitTorrentPT.WebUI}";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${lib.getExe' py "python3"} ${./cleanup.py}";
      Restart = "no";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
    after = [ "network.target" ];
  };

  systemd.timers.qbittorrent-pt-cleanup = {
    wantedBy = [ "timers.target" ];
    partOf = [ "qbittorrent-pt-cleanup.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "qbittorrent-pt-cleanup.service";
    };
  };
}
