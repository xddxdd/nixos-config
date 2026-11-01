{
  config,
  lib,
  pkgs,
  ...
}:
let
  btrfs-scrub-maybe-cancel = pkgs.writeShellApplication {
    name = "btrfs-scrub-maybe-cancel";
    runtimeInputs = [
      pkgs.btrfs-progs
      pkgs.coreutils
    ];
    text = ''
      stderr=$(mktemp)
      trap 'rm -f "$stderr"' EXIT
      status=0
      btrfs scrub cancel "$@" 2>"$stderr" || status=$?
      if (( status == 2 )); then
        exit 0
      fi
      cat "$stderr" >&2
      exit "$status"
    '';
  };
in
{
  systemd.services."btrfs-scrub@" = lib.mkIf config.services.btrfs.autoScrub.enable {
    serviceConfig.ExecStop = lib.mkForce "${lib.getExe btrfs-scrub-maybe-cancel} %f";
  };
}
