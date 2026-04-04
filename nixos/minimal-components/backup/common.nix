{
  lib,
  pkgs,
  ...
}:
rec {
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

  resticRepos = {
    home = ''
      [repository]
      repository = "opendal:sftp"
      password-file = "/run/agenix/restic-pw"
      cache-dir = "/var/cache/restic"

      [repository.options]
      user = "sftp"
      endpoint = "ssh://sftp.lt-home-vm.ltnet.xuyh0120.win:2222"
      key = "/run/agenix/sftp-privkey"
      root = "/backups/restic"
      known_hosts_strategy = "Accept"
      enable_copy = "true"

      [backup]
      custom-ignorefiles = ["${resticIgnored}"]
      git-ignore = true
      no-require-git = true
      no-scan = true
      one-file-system = true

      [forget]
      keep-last = 1
      keep-hourly = 0
      keep-daily = 7
      keep-weekly = 4
      keep-monthly = 1
      keep-yearly = 1
      prune = true
    '';
    storagebox = ''
      [repository]
      repository = "opendal:sftp"
      password-file = "/run/agenix/restic-pw"
      cache-dir = "/var/cache/restic"

      [repository.options]
      user = "u378583-sub2"
      endpoint = "ssh://sub2.u378583.your-storagebox.de:23"
      key = "/run/agenix/sftp-privkey"
      root = "/home"
      known_hosts_strategy = "Accept"
      enable_copy = "true"

      [backup]
      custom-ignorefiles = ["${resticIgnored}"]
      git-ignore = true
      no-require-git = true
      no-scan = true
      one-file-system = true

      [forget]
      keep-last = 1
      keep-hourly = 0
      keep-daily = 7
      keep-weekly = 4
      keep-monthly = 1
      keep-yearly = 1
      prune = true
    '';
  };

  maintenanceHosts = {
    "terrahost" = [ "storagebox" ];
    "lt-home-vm" = [ "home" ];
  };

  resticCommands = lib.mapAttrsToList (
    k: v:
    let
      configFile = pkgs.writeText "rustic-${k}.toml" v;
    in
    pkgs.writeShellScriptBin "rustic-${k}" ''
      export RUSTIC_USE_PROFILE=${configFile}
      exec ${lib.getExe pkgs.rustic} "$@"
    ''
  ) resticRepos;
}
