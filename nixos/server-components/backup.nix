{ pkgs, config, utils, ... }:

let
  kopiaStorage = {
    ibm-cos = {
      "type" = "s3";
      "config" = {
        "bucket" = { _secret = config.age.secrets.kopia-ibm-cos-bucket.path; };
        "endpoint" = "s3.us.cloud-object-storage.appdomain.cloud";
        "accessKeyID" = { _secret = config.age.secrets.kopia-ibm-cos-ak.path; };
        "secretAccessKey" = { _secret = config.age.secrets.kopia-ibm-cos-sk.path; };
        "sessionToken" = "";
      };
    };
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
  };

  kopiaIgnored = pkgs.writeText ".kopiaignore" ''
    media/
    sftp-server/
    sync-servers/
    var/cache/
    var/lib/btrfs/
    var/lib/cni/
    var/lib/containers/
    var/lib/docker/
    var/lib/docker-dind/
    var/lib/filebeat/
    var/lib/grafana/
    var/lib/machines/
    var/lib/os-prober/
    var/lib/private/
    var/lib/prometheus/
    var/lib/systemd/
    var/lib/udisks2/
    var/lib/vm/
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
    export KOPIA_LOG_DIR=/var/log/kopia
    export KOPIA_PASSWORD=$(cat ${config.age.secrets.kopia-pw.path})

    ${utils.genJqSecretsReplacementSnippet
      (kopiaConfig name storage)
      "/run/kopia-repository.config"}

    ${pkgs.kopia}/bin/kopia snapshot create \
      /nix/.snapshot/persistent

    rm -f $KOPIA_CONFIG_PATH
  '';
in
{
  age.secrets.kopia-ibm-cos-ak.file = pkgs.secrets + "/kopia/ibm-cos-ak.age";
  age.secrets.kopia-ibm-cos-bucket.file = pkgs.secrets + "/kopia/ibm-cos-bucket.age";
  age.secrets.kopia-ibm-cos-sk.file = pkgs.secrets + "/kopia/ibm-cos-sk.age";
  age.secrets.kopia-pw.file = pkgs.secrets + "/kopia/pw.age";
  age.secrets.kopia-scaleway-ak.file = pkgs.secrets + "/kopia/scaleway-ak.age";
  age.secrets.kopia-scaleway-bucket.file = pkgs.secrets + "/kopia/scaleway-bucket.age";
  age.secrets.kopia-scaleway-sk.file = pkgs.secrets + "/kopia/scaleway-sk.age";

  systemd.services.backup = {
    serviceConfig.Type = "oneshot";
    script = ''
      SNAPSHOT_DIR=/nix/.snapshot

    '' + (if config.fileSystems."/nix".fsType == "btrfs" then ''
      # Btrfs snapshot
      [ -e "$SNAPSHOT_DIR" ] && ${pkgs.btrfs-progs}/bin/btrfs subvolume delete $SNAPSHOT_DIR
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /nix $SNAPSHOT_DIR

    '' else ''
      # Fake snapshot with link
      [ -e "$SNAPSHOT_DIR" ] && rm -f $SNAPSHOT_DIR
      ln -s /nix $SNAPSHOT_DIR

    '') + (builtins.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList kopiaScript kopiaStorage
    )) + (if config.fileSystems."/nix".fsType == "btrfs" then ''
      # Remove snapshot
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete $SNAPSHOT_DIR

    '' else ''
      # Remove snapshot
      rm -f $SNAPSHOT_DIR

    '');
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
    "C /nix/persistent/.kopiaignore - - - - ${kopiaIgnored}"
  ] ++ (pkgs.lib.mapAttrsToList
    (n: v: "d /var/cache/kopia/${n} 700 root root")
    kopiaStorage);
}
