{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  isBtrfsRoot = (config.fileSystems."/nix".fsType or "") == "btrfs";

  inherit (pkgs.callPackage ./common.nix { inherit config; }) resticRepos resticCommands;

  resticIgnored = pkgs.writeText "ignored.txt" ''
    media/
    sftp-server/
    tmp/
    var/cache/
    var/lib/asterisk/
    var/lib/btrfs/
    var/lib/cni/
    var/lib/containers/
    var/lib/crowdsec/
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
    var/lib/vz/
    var/log/
  '';

  backupScript = path: repo: ''
    echo "Backing up ${path} to ${repo}"
    if [ ! -d "${path}" ]; then
      echo "${path} is not a directory, skipping"
    else
      restic-${repo} backup \
        ${path} \
        --iexclude-file ${resticIgnored} \
        --host ${config.networking.hostName} \
        --no-scan \
        || HAS_ERROR=1
    fi
  '';
in
{
  options.lantian.backupPaths = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          snapshotFrom = lib.mkOption {
            type = lib.types.str;
          };
          snapshotTo = lib.mkOption {
            type = lib.types.str;
          };
          backupPath = lib.mkOption {
            type = lib.types.str;
          };
        };
      }
    );
    default = [ ];
  };

  config = {
    lantian.backupPaths.nix-persistent = lib.mkIf isBtrfsRoot {
      snapshotFrom = "/nix";
      snapshotTo = "/nix/.snapshot";
      backupPath = "/nix/.snapshot/persistent";
    };

    age.secrets.restic-pw.file = inputs.secrets + "/restic/pw.age";
    age.secrets.sftp-privkey.file = inputs.secrets + "/sftp-privkey.age";

    environment.systemPackages = resticCommands;

    systemd.services = lib.mapAttrs' (
      n: v:
      lib.nameValuePair "backup-${n}" {
        serviceConfig = {
          Type = "oneshot";
          CPUQuota = "40%";
          OOMScoreAdjust = "1000";
        };
        unitConfig.OnFailure = "notify-email@%n.service";

        path = [
          pkgs.openssh
        ]
        ++ resticCommands;

        preStart = ''
          # Btrfs snapshot
          [ -e "${v.snapshotTo}" ] && ${lib.getExe pkgs.btrfs-progs} subvolume delete "${v.snapshotTo}"
          ${lib.getExe pkgs.btrfs-progs} subvolume snapshot -r "${v.snapshotFrom}" "${v.snapshotTo}"
        '';

        script = ''
          HAS_ERROR=0
          ${lib.concatMapStringsSep "\n" (backupScript v.backupPath) (builtins.attrNames resticRepos)}
          exit $HAS_ERROR
        '';

        # Remove snapshot
        postStop = ''
          ${lib.getExe pkgs.btrfs-progs} subvolume delete ${v.snapshotTo}
        '';
      }
    ) config.lantian.backupPaths;

    systemd.timers = lib.mapAttrs' (
      n: v:
      lib.nameValuePair "backup-${n}" {
        enable = isBtrfsRoot;
        wantedBy = [ "timers.target" ];
        partOf = [ "backup-${n}.service" ];
        timerConfig = {
          OnCalendar = "*-*-* 4:00:00";
          RandomizedDelaySec = "1h";
          Unit = "backup-${n}.service";
        };
      }
    ) config.lantian.backupPaths;

    systemd.tmpfiles.settings = {
      restic = {
        "/var/cache/restic".d = {
          mode = "700";
          user = "root";
          group = "root";
        };
      };
    };
  };
}
