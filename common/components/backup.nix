{ pkgs, config, ... }:

let
  backupScript = configPath: ''
    FILENAME=/var/backup/${config.networking.hostName}-$(${pkgs.coreutils}/bin/date +%Y-%m-%d).tar.zst

    ${pkgs.coreutils}/bin/mkdir -p /var/backup/
    ${pkgs.coreutils}/bin/rm -rf /var/backup/*

    ${pkgs.gnutar}/bin/tar \
      --exclude=/var/lib/containers \
      --exclude=/var/lib/docker \
      --exclude=/var/lib/docker-dind \
      -I ${pkgs.zstd}/bin/zstd -cf /var/backup/${config.networking.hostName}-$(date +%Y-%m-%d).tar.zst \
      /var/lib

    echo "Uploading to Dropbox"
    ${pkgs.rclone}/bin/rclone --config ${configPath} mkdir dropbox:/Backups/ || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} delete dropbox:"/Backups/${config.networking.hostName}-$(date +%Y-%m-%d --date='3 days ago').tar.zst" || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} copy $FILENAME dropbox:/Backups/ || ${pkgs.coreutils}/bin/true

    #echo "Uploading to OneDrive"
    #${pkgs.rclone}/bin/rclone --config ${configPath} mkdir onedrive:/Backups/ || ${pkgs.coreutils}/bin/true
    #${pkgs.rclone}/bin/rclone --config ${configPath} delete onedrive:"/Backups/${config.networking.hostName}-$(date +%Y-%m-%d --date='3 days ago').tar.zst" || ${pkgs.coreutils}/bin/true
    #${pkgs.rclone}/bin/rclone --config ${configPath} copy $FILENAME onedrive:/Backups/ || ${pkgs.coreutils}/bin/true

    echo "Uploading to Scaleway"
    ${pkgs.rclone}/bin/rclone --config ${configPath} mkdir scaleway:/Backups/ || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} delete scaleway:"/Backups/${config.networking.hostName}-$(date +%Y-%m-%d --date='5 days ago').tar.zst" || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} copy $FILENAME scaleway:/Backups/ || ${pkgs.coreutils}/bin/true
  '';
in
{
  age.secrets.rclone-conf.file = ../../secrets/rclone-conf.age;

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
}
