{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  isBtrfsRoot = (config.fileSystems."/nix".fsType or "") == "btrfs";

  kopiaStorage = {
    scaleway = {
      "type" = "s3";
      "config" = {
        "bucket" = { _secret = config.age.secrets.kopia-scaleway-bucket.path; };
        "endpoint" = "s3.fr-par.scw.cloud";
        "accessKeyID" = { _secret = config.age.secrets.kopia-scaleway-ak.path; };
        "secretAccessKey" = { _secret = config.age.secrets.kopia-scaleway-sk.path; };
        "sessionToken" = "";
      };
    };
    oneprovider = {
      "type" = "s3";
      "config" = {
        "bucket" = { _secret = config.age.secrets.kopia-minio-bucket.path; };
        "endpoint" = "s3.xuyh0120.win";
        "accessKeyID" = { _secret = config.age.secrets.kopia-minio-ak.path; };
        "secretAccessKey" = { _secret = config.age.secrets.kopia-minio-sk.path; };
        "sessionToken" = "";
      };
    };
    storj = {
      "type" = "s3";
      "config" = {
        "bucket" = { _secret = config.age.secrets.kopia-storj-bucket.path; };
        "endpoint" = "gateway.storjshare.io";
        "accessKeyID" = { _secret = config.age.secrets.kopia-storj-ak.path; };
        "secretAccessKey" = { _secret = config.age.secrets.kopia-storj-sk.path; };
        "sessionToken" = "";
      };
    };
  };

  kopiaIgnored = ''
    media/
    sftp-server/
    sync-servers/
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
    var/lib/machines/
    var/lib/matrix-synapse/media
    var/lib/minio/data
    var/lib/os-prober/
    var/lib/private/
    var/lib/prometheus/
    var/lib/resilio-sync/*.db
    var/lib/resilio-sync/*.db-wal
    var/lib/syncthing/*.db
    var/lib/systemd/
    var/lib/udisks2/
    var/lib/vm/
    var/lib/yggdrasil-alfis/
    var/log/
  '';

  kopiaConfig = name: storage: {
    inherit storage;
    "caching" = {
      "cacheDirectory" = "/var/cache/kopia/${name}";
      "maxCacheSize" = 10485760;
      "maxMetadataCacheSize" = 10485760;
      "maxListCacheDuration" = 30;
    };
    "hostname" = config.networking.hostName;
    "username" = "root";
    "description" = "Backup repository";
    "enableActions" = false;
    "formatBlobCacheDuration" = 900000000000;
  };

  kopiaScript = name: storage: ''
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
      /nix/.snapshot/persistent \
      || HAS_ERROR=1

    ${pkgs.kopia}/bin/kopia maintenance run || true

    rm -f $KOPIA_CONFIG_PATH
  '';
in
{
  age.secrets.kopia-minio-ak.file = inputs.secrets + "/kopia/minio-ak.age";
  age.secrets.kopia-minio-bucket.file = inputs.secrets + "/kopia/minio-bucket.age";
  age.secrets.kopia-minio-sk.file = inputs.secrets + "/kopia/minio-sk.age";
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
    script = ''
      SNAPSHOT_DIR=/nix/.snapshot
      HAS_ERROR=0

      cat >/nix/persistent/.kopiaignore <<EOF
      ${kopiaIgnored}
      EOF

    '' + (if isBtrfsRoot then ''
      # Btrfs snapshot
      [ -e "$SNAPSHOT_DIR" ] && ${pkgs.btrfs-progs}/bin/btrfs subvolume delete $SNAPSHOT_DIR
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /nix $SNAPSHOT_DIR

    '' else ''
      # Fake snapshot with link
      [ -e "$SNAPSHOT_DIR" ] && rm -f $SNAPSHOT_DIR
      ln -s /nix $SNAPSHOT_DIR

    '') + (builtins.concatStringsSep "\n" (
      lib.mapAttrsToList kopiaScript kopiaStorage
    )) + (if isBtrfsRoot then ''
      # Remove snapshot
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete $SNAPSHOT_DIR

    '' else ''
      # Remove snapshot
      rm -f $SNAPSHOT_DIR

    '') + ''
      exit $HAS_ERROR
    '';
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

  systemd.tmpfiles.rules = [
    "d /var/cache/kopia 700 root root"
    "d /var/log/kopia 700 root root"
  ] ++ (lib.mapAttrsToList
    (n: v: "d /var/cache/kopia/${n} 700 root root")
    kopiaStorage);
}
