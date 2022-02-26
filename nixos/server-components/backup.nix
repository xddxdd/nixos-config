{ pkgs, config, ... }:

let
  backupExcluded = [
    "/var/lib/btrfs"
    "/var/lib/cni"
    "/var/lib/containers"
    "/var/lib/docker"
    "/var/lib/docker-dind"
    "/var/lib/filebeat"
    "/var/lib/grafana"
    "/var/lib/journalbeat"
    "/var/lib/machines"
    "/var/lib/private"
    "/var/lib/systemd"
    "/var/lib/udisks2"
    "/var/lib/vm"
  ];

  backupExcludedRule = pkgs.writeText "excluded.list"
    (pkgs.lib.concatStringsSep "\n" backupExcluded);

  backupIncluded = [
    "/var/backup"
    "/var/lib"
  ];

  rcloneEnvironmentFile = pkgs.writeText "rclone-env" ''
    RCLONE_CONFIG=${config.age.secrets.rclone-conf.path}
  '';

  backupScript = configPath: ''
    export RCLONE_CONFIG=${config.age.secrets.rclone-conf.path}
    FILENAME=/nix/backup/${config.networking.hostName}-$(${pkgs.coreutils}/bin/date +%Y-%m-%d).tar.zst

    ${pkgs.coreutils}/bin/mkdir -p /nix/backup/
    ${pkgs.coreutils}/bin/rm -rf /nix/backup/*

    ${pkgs.gnutar}/bin/tar \
      ${builtins.concatStringsSep " " (builtins.map (v: "--exclude=${v}") backupExcluded)} \
      -I ${pkgs.zstd}/bin/zstd -cf /nix/backup/${config.networking.hostName}-$(date +%Y-%m-%d).tar.zst \
      ${builtins.concatStringsSep " " backupIncluded}

    # echo "Uploading to Dropbox"
    # ${pkgs.rclone}/bin/rclone mkdir dropbox:/Backups/ || ${pkgs.coreutils}/bin/true
    # ${pkgs.rclone}/bin/rclone delete dropbox:/Backups/${config.networking.hostName}-$(date +%Y-%m-%d --date='3 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    # ${pkgs.rclone}/bin/rclone copy $FILENAME dropbox:/Backups/ || ${pkgs.coreutils}/bin/true

    echo "Uploading to IBM COS"
    ${pkgs.rclone}/bin/rclone delete ibm:lantian/${config.networking.hostName}-$(date +%Y-%m-%d --date='3 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone copy $FILENAME ibm:lantian/ || ${pkgs.coreutils}/bin/true

    echo "Uploading to Scaleway"
    ${pkgs.rclone}/bin/rclone delete scaleway:lantian/${config.networking.hostName}-$(date +%Y-%m-%d --date='10 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone copy $FILENAME scaleway:lantian/ || ${pkgs.coreutils}/bin/true

    echo "Uploading to Soyoustart Backup FTP"
    ${pkgs.rclone}/bin/rclone delete sys-ftp:/${config.networking.hostName}-$(date +%Y-%m-%d --date='30 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone copy $FILENAME sys-ftp:/ || ${pkgs.coreutils}/bin/true
  '';
in
{
  age.secrets.rclone-conf.file = ../../secrets/rclone-conf.age;
  age.secrets.restic-pw.file = ../../secrets/restic-pw.age;

  systemd.services.backup = {
    serviceConfig.Type = "oneshot";
    script = backupScript config.age.secrets.rclone-conf.path;
  };

  systemd.timers.backup = {
    wantedBy = [ "timers.target" ];
    partOf = [ "backup.service" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Unit = "backup.service";
    };
  };

  services.restic.backups = {
    dropbox = {
      repository = "rclone:dropbox:/Backups";
      paths = backupIncluded;
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "4h";
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
      passwordFile = config.age.secrets.restic-pw.path;
      environmentFile = "${rcloneEnvironmentFile}";
      extraBackupArgs = [ "--iexclude-file=${backupExcludedRule}" ];
    };
  };
}
