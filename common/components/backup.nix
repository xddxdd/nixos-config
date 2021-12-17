{ pkgs, config, ... }:

let
  backupScript = configPath: ''
    FILENAME=/var/backup/${config.networking.hostName}-$(${pkgs.coreutils}/bin/date +%Y-%m-%d).tar.zst

    ${pkgs.coreutils}/bin/mkdir -p /var/backup/
    ${pkgs.coreutils}/bin/rm -rf /var/backup/*

    ${pkgs.gnutar}/bin/tar \
      --exclude=/var/lib/cni \
      --exclude=/var/lib/containers \
      --exclude=/var/lib/docker \
      --exclude=/var/lib/docker-dind \
      --exclude=/var/lib/journalbeat \
      --exclude=/var/lib/machines \
      --exclude=/var/lib/private \
      --exclude=/var/lib/systemd \
      --exclude=/var/lib/udisks2 \
      -I ${pkgs.zstd}/bin/zstd -cf /var/backup/${config.networking.hostName}-$(date +%Y-%m-%d).tar.zst \
      /var/lib

    echo "Uploading to Dropbox"
    ${pkgs.rclone}/bin/rclone --config ${configPath} mkdir dropbox:/Backups/ || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} delete dropbox:/Backups/${config.networking.hostName}-$(date +%Y-%m-%d --date='3 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} copy $FILENAME dropbox:/Backups/ || ${pkgs.coreutils}/bin/true

    #echo "Uploading to OneDrive"
    #${pkgs.rclone}/bin/rclone --config ${configPath} mkdir onedrive:/Backups/ || ${pkgs.coreutils}/bin/true
    #${pkgs.rclone}/bin/rclone --config ${configPath} delete onedrive:/Backups/${config.networking.hostName}-$(date +%Y-%m-%d --date='3 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    #${pkgs.rclone}/bin/rclone --config ${configPath} copy $FILENAME onedrive:/Backups/ || ${pkgs.coreutils}/bin/true

    echo "Uploading to IBM COS"
    ${pkgs.rclone}/bin/rclone --config ${configPath} delete ibm:lantian/${config.networking.hostName}-$(date +%Y-%m-%d --date='3 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} copy $FILENAME ibm:lantian/ || ${pkgs.coreutils}/bin/true

    echo "Uploading to Scaleway"
    ${pkgs.rclone}/bin/rclone --config ${configPath} delete scaleway:lantian/${config.networking.hostName}-$(date +%Y-%m-%d --date='10 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} copy $FILENAME scaleway:lantian/ || ${pkgs.coreutils}/bin/true

    echo "Uploading to Soyoustart Backup FTP"
    ${pkgs.rclone}/bin/rclone --config ${configPath} delete sys-ftp:/${config.networking.hostName}-$(date +%Y-%m-%d --date='30 days ago').tar.zst || ${pkgs.coreutils}/bin/true
    ${pkgs.rclone}/bin/rclone --config ${configPath} copy $FILENAME sys-ftp:/ || ${pkgs.coreutils}/bin/true
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
