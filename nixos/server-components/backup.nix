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

  backupPaths = [
    "/nix/.snapshot/persistent"
    "/mnt/storage/palworld-backup"
  ];

  kopiaSftpStorageCommon = {
    "port" = 2222;
    "username" = "sftp";
    "password" = "";
    "keyfile" = config.age.secrets.sftp-privkey.path;
    "knownHostsFile" = "/etc/ssh/ssh_known_hosts";
    "externalSSH" = false;
    "sshCommand" = "ssh";
    "dirShards" = null;
  };

  kopiaStorage = {
    hetzner-storagebox = {
      "type" = "sftp";
      "config" =
        kopiaSftpStorageCommon
        // {
          "username" = "u378583-sub1";
          "port" = 23;
          "path" = "/home";
          "host" = "u378583.your-storagebox.de";
        };
    };
    lt-home-vm = {
      "type" = "sftp";
      "config" =
        kopiaSftpStorageCommon
        // {
          "path" = "/backups-kopia";
          "host" = "lt-home-vm.lantian.pub";
        };
    };
    storj = {
      "type" = "s3";
      "config" = {
        "bucket" = {_secret = config.age.secrets.kopia-storj-bucket.path;};
        "endpoint" = "gateway.storjshare.io";
        "accessKeyID" = {_secret = config.age.secrets.kopia-storj-ak.path;};
        "secretAccessKey" = {_secret = config.age.secrets.kopia-storj-sk.path;};
        "sessionToken" = "";
      };
    };
  };

  kopiaIgnored = ''
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

  kopiaConfig = name: storage: {
    inherit storage;
    "caching" = {
      "cacheDirectory" = "/var/cache/kopia/${name}";
      "maxCacheSize" = 1073741824;
      "maxMetadataCacheSize" = 1073741824;
      "maxListCacheDuration" = 30;
    };
    "hostname" = config.networking.hostName;
    "username" = "root";
    "description" = "Backup repository";
    "enableActions" = false;
    "formatBlobCacheDuration" = 900000000000;
  };

  kopiaScript = path: name: storage: (''
      echo "Backing up ${path} to ${name}"
      if [ ! -d "${path}" ]; then
        echo "${path} is not a directory, skipping"
      else
        export GOGC=10

        export KOPIA_CACHE_DIRECTORY=/var/cache/kopia/${name}
        export KOPIA_CONFIG_PATH=/run/kopia-repository.config

        if [ -d /run/nullfs ]; then
          export KOPIA_LOG_DIR=/run/nullfs
        else
          export KOPIA_LOG_DIR=/var/log/kopia
        fi

        export KOPIA_PASSWORD=$(cat ${config.age.secrets.kopia-pw.path})

        ${utils.genJqSecretsReplacementSnippet
        (kopiaConfig name storage)
        "/run/kopia-repository.config"}

        ${pkgs.kopia}/bin/kopia snapshot create \
          --parallel=5 \
          ${path} \
          || HAS_ERROR=1
    ''
    + (lib.optionalString isMaintenanceHost ''
      ${pkgs.kopia}/bin/kopia maintenance set --owner=root@${config.networking.hostName}
      ${pkgs.kopia}/bin/kopia maintenance run --log-level=debug
    '')
    + ''
        rm -rf "$KOPIA_CACHE_DIRECTORY"/*
        rm -f $KOPIA_CONFIG_PATH
      fi
    '');
in {
  age.secrets.kopia-pw.file = inputs.secrets + "/kopia/pw.age";
  age.secrets.kopia-scaleway-ak.file = inputs.secrets + "/kopia/scaleway-ak.age";
  age.secrets.kopia-scaleway-bucket.file = inputs.secrets + "/kopia/scaleway-bucket.age";
  age.secrets.kopia-scaleway-sk.file = inputs.secrets + "/kopia/scaleway-sk.age";
  age.secrets.kopia-storj-ak.file = inputs.secrets + "/kopia/storj-ak.age";
  age.secrets.kopia-storj-bucket.file = inputs.secrets + "/kopia/storj-bucket.age";
  age.secrets.kopia-storj-sk.file = inputs.secrets + "/kopia/storj-sk.age";
  age.secrets.sftp-privkey.file = inputs.secrets + "/sftp-privkey.age";

  systemd.services.backup = {
    serviceConfig = {
      Type = "oneshot";
      CPUQuota = "40%";
    };
    unitConfig.OnFailure = "notify-email-fail@%n.service";

    environment = {
      SNAPSHOT_DIR = "/nix/.snapshot";
    };

    preStart =
      ''
        cat >/nix/persistent/.kopiaignore <<EOF
        ${kopiaIgnored}
        EOF
      ''
      + (
        if isBtrfsRoot
        then ''
          # Btrfs snapshot
          [ -e "$SNAPSHOT_DIR" ] && ${pkgs.btrfs-progs}/bin/btrfs subvolume delete $SNAPSHOT_DIR
          ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /nix $SNAPSHOT_DIR
        ''
        else ''
          # Fake snapshot with link
          [ -e "$SNAPSHOT_DIR" ] && rm -f $SNAPSHOT_DIR
          ln -s /nix $SNAPSHOT_DIR
        ''
      );

    script =
      ''
        HAS_ERROR=0
      ''
      + (builtins.concatStringsSep "\n" (lib.flatten (builtins.map (path: (
          lib.mapAttrsToList (kopiaScript path) kopiaStorage
        ))
        backupPaths)))
      + ''
        exit $HAS_ERROR
      '';

    # Remove snapshot
    postStop =
      if isBtrfsRoot
      then ''
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete $SNAPSHOT_DIR
      ''
      else ''
        rm -f $SNAPSHOT_DIR
      '';
  };

  systemd.timers.backup = {
    wantedBy = ["timers.target"];
    partOf = ["backup.service"];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Unit = "backup.service";
    };
  };

  systemd.tmpfiles.rules =
    [
      "d /var/cache/kopia 700 root root"
      "d /var/log/kopia 700 root root"
    ]
    ++ (lib.mapAttrsToList
      (n: v: "d /var/cache/kopia/${n} 700 root root")
      kopiaStorage);
}
