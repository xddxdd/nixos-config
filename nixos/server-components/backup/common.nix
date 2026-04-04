{
  lib,
  pkgs,
  config,
  ...
}:
rec {
  resticRepos = {
    home = "sftp://sftp.lt-home-vm.ltnet.xuyh0120.win//backups/restic";
    storagebox = "sftp://sub2.u378583.your-storagebox.de//home";
  };

  maintenanceHosts = {
    "terrahost" = [ "storagebox" ];
    "lt-home-vm" = [ "home" ];
  };

  resticCommands = lib.mapAttrsToList (
    k: v:
    pkgs.writeShellScriptBin "restic-${k}" ''
      export RESTIC_REPOSITORY=${v}
      export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-pw.path}
      export RESTIC_CACHE_DIR=/var/cache/restic
      export RESTIC_COMPRESSION=max

      exec ${lib.getExe pkgs.restic} "$@"
    ''
  ) resticRepos;
}
