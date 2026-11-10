{
  config,
  pkgs,
  ...
}:
{
  systemd.services.rsgain-cloudmusic = {
    path = [
      pkgs.parallel
      pkgs.rsgain
    ];
    script = ''
      IFS=$'\n'

      LIST="$STATE_DIRECTORY/processed.lst"
      QUEUE="$STATE_DIRECTORY/queue.lst"
      touch "$LIST"
      : > "$QUEUE"

      for FILE in $(find /mnt/storage/syncthing/CloudMusic -type f -iname \*.mp3 -or -iname \*.m4a -or -iname \*.ogg -or -iname \*.flac); do
        grep -qxF -- "$FILE" "$LIST" && continue
        echo "rsgain custom --tagmode=i --loudness=-14 \"$FILE\" && echo \"$FILE\" >> \"$LIST\"" >> "$QUEUE"
      done
      for FILE in $(find /mnt/storage/syncthing/CloudMusicArchive -type f -iname \*.mp3 -or -iname \*.m4a -or -iname \*.ogg -or -iname \*.flac); do
        grep -qxF -- "$FILE" "$LIST" && continue
        echo "rsgain custom --tagmode=i --loudness=-14 \"$FILE\" && echo \"$FILE\" >> \"$LIST\"" >> "$QUEUE"
      done
      parallel -j$(nproc) < "$QUEUE"
    '';

    serviceConfig = {
      Type = "oneshot";
      ReadWritePaths = [
        "/mnt/storage/syncthing/CloudMusic"
        "/mnt/storage/syncthing/CloudMusicArchive"
      ];
      StateDirectory = "rsgain-cloudmusic";
      WorkingDirectory = "/var/lib/rsgain-cloudmusic";

      # Allow rsgain to read/write files created by syncthing
      AmbientCapabilities = [ "CAP_DAC_OVERRIDE" ];
      CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" ];
    };
    unitConfig = {
      RequiresMountsFor = config.systemd.services.rsgain-cloudmusic.serviceConfig.ReadWritePaths;
      OnFailure = "notify-email@%n.service";
    };
  };

  lantian.harden.rsgain-cloudmusic = {
    enable = true;
    enableConfinement = false;
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
