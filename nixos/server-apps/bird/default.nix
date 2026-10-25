{
  pkgs,
  lib,
  LT,
  config,
  ...
}@args:
let
  anycast = import ./config/anycast.nix args;
  dn42 = import ./config/dn42.nix args;
  ltnet = import ./config/ltnet.nix args;
  sys = import ./config/sys.nix args;
in
{
  lantian.firewall.presets.public-firewall.firewalledPorts = lib.mkIf config.services.bird.enable [
    LT.port.BGP
  ];

  imports = [
    ./bgp-flowspec.nix
    ./stayrtr.nix
  ];

  services.bird = {
    enable = true;
    package = pkgs.bird2;
    checkConfig = false;
    config = builtins.concatStringsSep "\n" (
      [
        sys.common
        sys.network
        sys.static
        sys.kernel
        # sys.flowspec
        anycast.babel

        # Used by ltnet
        dn42.communityFilters
      ]
      ++ lib.optionals (LT.this.hasTag LT.tags.dn42) [
        sys.roa
        sys.roaFlapAlerted
        sys.roaMonitor
        sys.flapAlerted

        dn42.common
        dn42.peers
        dn42.staticRoutes
        (lib.optionalString dn42.hasPeers dn42.grc)
      ]
      ++ [
        ltnet.common
        # ltnet.dynamic
        ltnet.peers
      ]
    );
  };

  users = {
    users.bird = {
      description = "BIRD Internet Routing Daemon user";
      group = "bird";
      isSystemUser = true;
    };
    groups.bird = { };
  };

  environment.etc."bird/bird.conf".mode = "0444";

  systemd.services.bird.serviceConfig = {
    # Keep the original foreground command and host-filesystem access.
    Type = lib.mkForce "simple";
    ExecStart = lib.mkForce "${lib.getExe' pkgs.bird2 "bird"} -f -c /etc/bird/bird.conf";
    ExecReload = lib.mkForce "${lib.getExe' pkgs.bird2 "birdc"} configure";
    ExecStop = lib.mkForce "";

    CPUQuota = "10%";
    Restart = lib.mkForce "always";
    RestartSec = "5s";

    User = "bird";
    Group = "bird";
    RuntimeDirectory = lib.mkForce "bird";
    # Confined clients must retain this inode even across a full stop/start.
    RuntimeDirectoryPreserve = "yes";
    # Preserve the network preset where upstream defines conflicting values.
    PrivateDevices = lib.mkForce false;
    ProtectControlGroups = lib.mkForce false;
    ProtectSystem = lib.mkForce "strict";
    ProtectHome = lib.mkForce true;
    MemoryDenyWriteExecute = lib.mkForce true;
    SystemCallFilter = lib.mkForce [ ];
    # Manages host kernel routes
    PrivateUsers = false;
    # Keep the control socket reachable by birdc and confined consumers.
    BindPaths = [ "/run/bird" ];
    BindReadOnlyPaths = [ "/etc/bird" ];
  };
  lantian.harden.bird = {
    enable = "network";
    enableConfinement = false;
  };

  systemd.tmpfiles.settings = {
    bird-config = {
      "/nix/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa4.conf"."f" = {
        mode = "644";
        user = "root";
        group = "root";
      };
      "/nix/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa6.conf"."f" = {
        mode = "644";
        user = "root";
        group = "root";
      };
      "/nix/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa4.conf"."f" = {
        mode = "644";
        user = "root";
        group = "root";
      };
      "/nix/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa6.conf"."f" = {
        mode = "644";
        user = "root";
        group = "root";
      };
    };
  };

  services.prometheus.exporters = {
    bird = {
      enable = LT.this.hasTag LT.tags.server && LT.this.hasTag LT.tags.dn42;
      port = LT.port.Prometheus.BirdExporter;
      listenAddress = LT.this.ltnet.IPv4;
      birdSocket = "/run/bird/bird.ctl";
    };
  };

  systemd.services."prometheus-bird-exporter" = {
    wants = [ "bird.service" ];
    after = [ "bird.service" ];
    serviceConfig = {
      RestartSec = "5s";
      ProcSubset = "all";
      ProtectProc = "default";
      BindReadOnlyPaths = [ "/run/bird" ];
    };
  };
  lantian.harden.prometheus-bird-exporter.enable = true;

  systemd.services.bird-lgproxy-go = {
    enable = LT.this.hasTag LT.tags.server && LT.this.hasTag LT.tags.dn42;
    description = "Bird-lgproxy-go";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.traceroute ];
    environment = {
      BIRD_SOCKET = "/run/bird/bird.ctl";
      BIRDLG_LISTEN = "${LT.this.ltnet.IPv4}:8000";
      BIRDLG_TRACEROUTE_BIN = lib.getExe' pkgs.traceroute "traceroute";
    };
    unitConfig = {
      After = "bird.service";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = lib.getExe pkgs.nur-xddxdd.bird-lgproxy-go;

      # Needed by mtr and traceroute
      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
      ];
      SystemCallFilter = [ ];

      Group = "bird";
      User = "bird";

      CPUQuota = "10%";
      # Privileged operations need host-level capabilities
      PrivateUsers = false;
      BindReadOnlyPaths = [ "/run/bird" ];
    };
  };
  lantian.harden.bird-lgproxy-go.enable = true;
}
