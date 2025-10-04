{
  pkgs,
  lib,
  LT,
  config,
  ...
}@args:
let
  anycast = import ./anycast.nix args;
  dn42 = import ./dn42.nix args;
  ltnet = import ./ltnet.nix args;
  sys = import ./sys.nix args;
in
{
  services.bird = {
    enable = LT.this.hasTag LT.tags.server;
    package = pkgs.bird2;
    checkConfig = false;
    config = builtins.concatStringsSep "\n" (
      [
        sys.common
        sys.network
        sys.static
        sys.kernel
        anycast.babel

        # Used by ltnet
        dn42.communityFilters
      ]
      ++ lib.optionals (LT.this.hasTag LT.tags.dn42) [
        sys.roa
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
      ExecStart = "${pkgs.bird2}/bin/bird -f -c /etc/bird/bird.conf";
      ExecReload = "${pkgs.bird2}/bin/birdc configure";

      CPUQuota = "10%";
      Restart = lib.mkForce "always";

      User = "bird";
      Group = "bird";
      RuntimeDirectory = "bird";
    }
  );

  systemd.tmpfiles.rules = [
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa4.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa6.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa4.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa6.conf 644 root root - # placebo"
  ];

  services.prometheus.exporters = {
    bird = {
      enable = LT.this.hasTag LT.tags.server;
      port = LT.port.Prometheus.BirdExporter;
      listenAddress = LT.this.ltnet.IPv4;
      birdSocket = "/var/run/bird/bird.ctl";
    };
  };

  systemd.services.bird-lgproxy-go = {
    enable = LT.this.hasTag LT.tags.server;
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
