{
  pkgs,
  lib,
  config,
  inputs,
  LT,
  ...
}:
let
  cfg = config.lantian.backup;

  isBtrfsRoot = (config.fileSystems."/nix".fsType or "") == "btrfs";

  inherit (pkgs.callPackage ./common.nix { inherit config; })
    resticIgnored
    resticRepos
    resticCommands
    ;

  backupScript = path: repo: ignoreFile: ''
    echo "Backing up ${path} to ${repo}"
    if [ ! -d "${path}" ]; then
      echo "${path} is not a directory, skipping"
    else
      rustic-${repo} backup ${path} --host ${config.networking.hostName} --custom-ignorefile ${ignoreFile} || HAS_ERROR=1
    fi
  '';
in
{
  options.lantian.backup = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = LT.this.hasTag LT.tags.server;
    };
    resticRepos = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtins.attrNames resticRepos;
    };
    schedule = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "*-*-* 4:00:00";
    };
    persistentTimer = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    paths = lib.mkOption {
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
            ignored = lib.mkOption {
              type = lib.types.lines;
              default = resticIgnored;
            };
          };
        }
      );
      default = [ ];
    };
  };

  config = lib.mkMerge [
    {
      age.secrets.restic-pw.file = inputs.secrets + "/restic/pw.age";
      age.secrets.sftp-privkey.file = inputs.secrets + "/sftp-privkey.age";

      environment.systemPackages = resticCommands ++ [ pkgs.rustic ];
    }
    (lib.mkIf cfg.enable {
      lantian.backup.paths.nix-persistent = lib.mkIf isBtrfsRoot {
        snapshotFrom = "/nix";
        snapshotTo = "/nix/.snapshot";
        backupPath = "/nix/.snapshot/persistent";
      };

      systemd.services = lib.mapAttrs' (
        n: v:
        lib.nameValuePair "backup-${n}" {
          serviceConfig = {
            Type = "oneshot";
            CPUQuota = "40%";
            OOMScoreAdjust = "1000";
            TimeoutStopSec = 600;
          };
          unitConfig = lib.optionalAttrs (!(LT.this.hasTag LT.tags.client)) {
            OnFailure = "notify-email@%n.service";
          };

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
            ${lib.concatMapStringsSep "\n" (
              repo: backupScript v.backupPath repo (pkgs.writeText "ignored.txt" v.ignored)
            ) cfg.resticRepos}
            exit $HAS_ERROR
          '';

          # Remove snapshot
          postStop = ''
            ${lib.getExe pkgs.btrfs-progs} subvolume delete ${v.snapshotTo}
          '';
        }
      ) cfg.paths;

      systemd.timers = lib.mapAttrs' (
        n: v:
        lib.nameValuePair "backup-${n}" {
          enable = cfg.schedule != null;
          wantedBy = [ "timers.target" ];
          partOf = [ "backup-${n}.service" ];
          timerConfig = {
            OnCalendar = cfg.schedule;
            RandomizedDelaySec = "1h";
            Unit = "backup-${n}.service";
            Persistent = cfg.persistentTimer;
          };
        }
      ) cfg.paths;

      systemd.tmpfiles.settings = {
        restic = {
          "/var/cache/restic".d = {
            mode = "700";
            user = "root";
            group = "root";
          };
        };
      };
    })
  ];
}
