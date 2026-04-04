{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs.callPackage ./common.nix { inherit config; }) resticCommands maintenanceHosts;

  pruneScript = repo: ''
    echo "Pruning ${repo}"

    restic-${repo} unlock
    restic-${repo} forget \
      --keep-last=1 \
      --keep-hourly=0 \
      --keep-daily=7 \
      --keep-weekly=4 \
      --keep-monthly=1 \
      --keep-yearly=1 \
      --prune \
      || HAS_ERROR=1
  '';
in
{
  systemd.services.backup-prune = lib.mkIf (lib.hasAttr config.networking.hostName maintenanceHosts) {
    serviceConfig = {
      Type = "oneshot";
      CPUQuota = "40%";
    };
    unitConfig.OnFailure = "notify-email@%n.service";

    path = [
      pkgs.openssh
    ]
    ++ resticCommands;

    script = ''
      HAS_ERROR=0
      ${lib.concatMapStringsSep "\n" pruneScript maintenanceHosts."${config.networking.hostName}"}
      exit $HAS_ERROR
    '';
  };

  systemd.timers.backup-prune = lib.mkIf (lib.hasAttr config.networking.hostName maintenanceHosts) {
    wantedBy = [ "timers.target" ];
    partOf = [ "backup-prune.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 16:00:00";
      RandomizedDelaySec = "1h";
      Unit = "backup-prune.service";
    };
  };

}
