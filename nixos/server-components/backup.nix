{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  isBtrfsRoot = (config.fileSystems."/nix".fsType or "") == "btrfs";
  isMaintenanceHost = config.networking.hostName == "terrahost";

  resticRepos = [
    "sftp://sftp.lt-home-vm.xuyh0120.win//backups-restic"
    "sftp://sub2.u378583.your-storagebox.de//home"
  ];

  backupPaths = [
    "/nix/.snapshot/persistent"
    "/mnt/storage/palworld-backup"
  ];

  resticIgnored = pkgs.writeText "ignored.txt" ''
    media/
    sftp-server/
    tmp/
    var/cache/
    var/lib/asterisk/
    var/lib/btrfs/
    var/lib/cni/
    var/lib/containers/
    var/lib/docker/
    var/lib/docker-dind/
    var/lib/filebeat/
    var/lib/GeoIP/
    var/lib/grafana/
    var/lib/jellyfin/transcodes/
    var/lib/libvirt/
    var/lib/machines/
    var/lib/os-prober/
    var/lib/private/
    var/lib/prometheus/
    var/lib/resilio-sync/*.db
    var/lib/resilio-sync/*.db-wal
    var/lib/samba/private/
    var/lib/systemd/
    var/lib/udisks2/
    var/lib/vm/
    var/log/
  '';

  backupScript = path: repo: ''
    echo "Backing up ${path} to ${repo}"
    if [ ! -d "${path}" ]; then
      echo "${path} is not a directory, skipping"
    else
      export RESTIC_REPOSITORY=${repo}
      export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-pw.path}
      export RESTIC_CACHE_DIR=/var/cache/restic
      export RESTIC_COMPRESSION=max

      restic backup ${path} \
        --iexclude-file ${resticIgnored} \
        --host ${config.networking.hostName} \
        --no-scan \
        || HAS_ERROR=1
    fi
  '';

  pruneScript = repo: ''
    export RESTIC_REPOSITORY=${repo}
    export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-pw.path}
    export RESTIC_CACHE_DIR=/var/cache/restic
    export RESTIC_COMPRESSION=max

    echo "Pruning ${repo}"

    restic unlock
    restic forget \
      --keep-last=1 \
      --keep-hourly=0 \
      --keep-daily=7 \
      --keep-weekly=4 \
      --keep-monthly=1 \
      --keep-yearly=1 \
      --prune \
      || HAS_ERROR=1
  '';
in {
  age.secrets.restic-pw.file = inputs.secrets + "/restic/pw.age";
  age.secrets.sftp-privkey.file = inputs.secrets + "/sftp-privkey.age";

  systemd.services.backup = {
    enable = isBtrfsRoot;
    serviceConfig = {
      Type = "oneshot";
      CPUQuota = "40%";
    };
    unitConfig.OnFailure = "notify-email-fail@%n.service";

    path = with pkgs; [
      openssh
      restic
    ];

    environment = {
      SNAPSHOT_DIR = "/nix/.snapshot";
    };

    preStart = ''
      # Btrfs snapshot
      [ -e "$SNAPSHOT_DIR" ] && ${pkgs.btrfs-progs}/bin/btrfs subvolume delete $SNAPSHOT_DIR
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /nix $SNAPSHOT_DIR
    '';

    script =
      ''
        HAS_ERROR=0
      ''
      + (builtins.concatStringsSep "\n"
        (lib.flatten
          (builtins.map
            (path: (
              builtins.map (repo: (backupScript path) repo) resticRepos
            ))
            backupPaths)))
      + ''
        exit $HAS_ERROR
      '';

    # Remove snapshot
    postStop = ''
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete $SNAPSHOT_DIR
    '';
  };

  systemd.timers.backup = {
    enable = isBtrfsRoot;
    wantedBy = ["timers.target"];
    partOf = ["backup.service"];
    timerConfig = {
      OnCalendar = "*-*-* 4:00:00";
      RandomizedDelaySec = "1h";
      Unit = "backup.service";
    };
  };

  systemd.services.backup-prune = {
    enable = isMaintenanceHost;
    serviceConfig = {
      Type = "oneshot";
      CPUQuota = "40%";
    };
    unitConfig.OnFailure = "notify-email-fail@%n.service";

    path = with pkgs; [
      openssh
      restic
    ];

    script =
      ''
        HAS_ERROR=0
      ''
      + (builtins.concatStringsSep "\n" (builtins.map pruneScript resticRepos))
      + ''
        exit $HAS_ERROR
      '';
  };

  systemd.timers.backup-prune = {
    enable = isMaintenanceHost;
    wantedBy = ["timers.target"];
    partOf = ["backup-prune.service"];
    timerConfig = {
      OnCalendar = "*-*-* 16:00:00";
      RandomizedDelaySec = "1h";
      Unit = "backup-prune.service";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/cache/restic 700 root root"
  ];
}
