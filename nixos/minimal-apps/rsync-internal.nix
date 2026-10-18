{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  isPrimaryServer = builtins.hasAttr "rsync-internal" config.users.users;
in
{
  systemd.tmpfiles.settings = {
    sync-servers = {
      "/nix/sync-servers".d = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };

  ########################################
  # Client
  ########################################

  systemd.services.rsync-nix-sync-servers = {
    enable = !isPrimaryServer;
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      BindPaths = [ "/nix/sync-servers" ];
      ExecStart = builtins.concatStringsSep " " [
        (lib.getExe pkgs.rsync)
        "-aczrq"
        "--delete-after"
        "--timeout=300"
        "rsync-internal:."
        "/nix/sync-servers/"
      ];
    };

    path = [ pkgs.rsync ];

    postStart = ''
      set -x
    ''
    + (lib.optionalString config.services.nginx.enable ''
      systemctl reload nginx.service || true
    '')
    + (lib.optionalString config.services.pdns-recursor.enable ''
      systemctl reload pdns-recursor.service || true
    '')
    + (lib.optionalString config.services.knot.enable ''
      systemctl reload knot.service || true
    '');
  };

  systemd.timers.rsync-nix-sync-servers = {
    enable = !isPrimaryServer;
    wantedBy = [ "timers.target" ];
    partOf = [ "rsync-nix-sync-servers.service" ];
    timerConfig = {
      OnCalendar = "*:0/10";
      RandomizedDelaySec = "10min";
      Unit = "rsync-nix-sync-servers.service";
    };
  };
}
