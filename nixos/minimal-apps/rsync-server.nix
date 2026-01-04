{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  primaryServer = "colocrossing";
in
{
  ########################################
  # Server
  ########################################

  services.rsyncd = {
    enable = config.networking.hostName == primaryServer;
    port = LT.port.Rsync;
    socketActivated = true;
    settings = {
      globalSection = {
        address = LT.this.ltnet.IPv4;
        gid = "root";
        uid = "root";
        "use chroot" = true;
      };

      sections = {
        sync-servers = {
          "read only" = true;
          "hosts allow" = "198.18.0.0/15";
          path = "/nix/persistent/sync-servers";
        };
      };
    };
  };

  systemd.services.rsync.serviceConfig = LT.serviceHarden // {
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    ReadOnlyPaths = [ "/nix/persistent/sync-servers" ];
  };

  systemd.sockets.rsync = {
    listenStreams = lib.mkForce [ "${LT.this.ltnet.IPv4}:${LT.portStr.Rsync}" ];
    socketConfig.FreeBind = true;
  };

  ########################################
  # Client
  ########################################

  systemd.services.rsync-nix-persistent-sync-servers = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      BindPaths = [ "/nix/persistent/sync-servers" ];
      ExecStart =
        if config.networking.hostName != primaryServer then
          builtins.concatStringsSep " " [
            (lib.getExe pkgs.rsync)
            "-aczrq"
            "--delete-after"
            "--timeout=300"
            "rsync://${LT.hosts.${primaryServer}.ltnet.IPv4}/sync-servers/"
            "/nix/persistent/sync-servers/"
          ]
        else
          # For primary server, do not run sync, but still run reload
          (lib.getExe' pkgs.coreutils "true");
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
    '');
  };

  systemd.timers.rsync-nix-persistent-sync-servers = {
    enable = config.networking.hostName != primaryServer;
    wantedBy = [ "timers.target" ];
    partOf = [ "rsync-nix-persistent-sync-servers.service" ];
    timerConfig = {
      OnCalendar = "*:0/10";
      RandomizedDelaySec = "10min";
      Unit = "rsync-nix-persistent-sync-servers.service";
    };
  };
}
