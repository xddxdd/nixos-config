{
  pkgs,
  lib,
  LT,
  ...
}@args:
let
  anycast = import ./config/anycast.nix args;
  dn42 = import ./config/dn42.nix args;
  ltnet = import ./config/ltnet.nix args;
  sys = import ./config/sys.nix args;
in
{
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

  systemd.services.bird.serviceConfig = lib.mkForce (
    LT.networkToolHarden
    // {
      ExecStart = "${lib.getExe' pkgs.bird2 "bird"} -f -c /etc/bird/bird.conf";
      ExecReload = "${lib.getExe' pkgs.bird2 "birdc"} configure";

      CPUQuota = "10%";
      Restart = lib.mkForce "always";

      User = "bird";
      Group = "bird";
      RuntimeDirectory = "bird";
    }
  );

  systemd.tmpfiles.settings = {
    bird-config = {
      "/nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa4.conf"."f" = {
        mode = "644";
        user = "root";
        group = "root";
      };
      "/nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa6.conf"."f" = {
        mode = "644";
        user = "root";
        group = "root";
      };
      "/nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa4.conf"."f" = {
        mode = "644";
        user = "root";
        group = "root";
      };
      "/nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa6.conf"."f" = {
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
      birdSocket = "/var/run/bird/bird.ctl";
    };
  };

  systemd.services.bird-lgproxy-go = {
    enable = LT.this.hasTag LT.tags.server && LT.this.hasTag LT.tags.dn42;
    description = "Bird-lgproxy-go";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      # mtr
      traceroute
    ];
    environment = {
      BIRD_SOCKET = "/run/bird/bird.ctl";
      BIRDLG_LISTEN = "${LT.this.ltnet.IPv4}:8000";
    };
    unitConfig = {
      After = "bird.service";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur-xddxdd.bird-lgproxy-go}/bin/proxy";

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
    };
  };
}
