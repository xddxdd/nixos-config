{ pkgs, LT, ... }:
{
  systemd.services.rsgain-cloudmusic = {
    path = [
      pkgs.parallel
      pkgs.rsgain
    ];
    script = ''
      IFS=$'\n'

      for FILE in $(find /mnt/storage/media/CloudMusic -type f -iname \*.mp3 -or -iname \*.m4a -or -iname \*.ogg -or -iname \*.flac); do
        echo "rsgain custom --skip-existing --tagmode=i \"$FILE\"" >> parallel.lst
      done
      parallel -j$(nproc) < parallel.lst
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ReadWritePaths = [ "/mnt/storage/media/CloudMusic" ];
      RuntimeDirectory = "rsgain-cloudmusic";
      WorkingDirectory = "/run/rsgain-cloudmusic";
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
