{ pkgs, LT, ... }:
{
  systemd.services.rsgain-cloudmusic = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${pkgs.rsgain}/bin/rsgain easy -m MAX -S /mnt/storage/media/CloudMusic";
      ReadWritePaths = [ "/mnt/storage/media/CloudMusic" ];
    };
  };

  systemd.timers.rsgain-cloudmusic = {
    wantedBy = [ "timers.target" ];
    partOf = [ "rsgain-cloudmusic.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "rsgain-cloudmusic.service";
    };
  };
}
