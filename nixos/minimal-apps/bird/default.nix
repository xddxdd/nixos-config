{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  anycast = import ./anycast.nix args;
  dn42 = import ./dn42.nix args;
  ltnet = import ./ltnet.nix args;
  sys = import ./sys.nix args;
in {
  services.bird2 = {
    enable = true;
    checkConfig = false;
    config = builtins.concatStringsSep "\n" ([
        sys.common
        sys.network
        sys.static
        sys.kernel
        anycast.babel

        # Used by ltnet
        dn42.communityFilters
      ]
      ++ lib.optionals (builtins.elem LT.tags.server LT.this.tags) [
        sys.roa
        sys.roaMonitor

        dn42.common
        dn42.peers
        dn42.staticRoutes
        (lib.optionalString dn42.hasPeers dn42.grc)
      ]
      ++ lib.optionals (!LT.this.ltnet.alone) [
        ltnet.common
        ltnet.dynamic
        ltnet.peers
      ]);
  };

  systemd.services.bird2.serviceConfig = lib.mkForce (LT.serviceHarden
    // {
      ExecStart = "${pkgs.bird}/bin/bird -f -c /etc/bird/bird2.conf";
      ExecReload = "${pkgs.bird}/bin/birdc configure";

      CPUQuota = "10%";
      Restart = lib.mkForce "always";

      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/bird.nix
      AmbientCapabilities = ["CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW"];
      CapabilityBoundingSet = ["CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW"];
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
      SystemCallFilter = "~@cpu-emulation @debug @keyring @module @mount @obsolete @raw-io";

      User = "bird2";
      Group = "bird2";
      RuntimeDirectory = "bird";
    });

  systemd.tmpfiles.rules = [
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa4.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa6.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa4.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa6.conf 644 root root - # placebo"
  ];

  services.prometheus.exporters = {
    bird = {
      enable = builtins.elem LT.tags.server LT.this.tags;
      port = LT.port.Prometheus.BirdExporter;
      listenAddress = LT.this.ltnet.IPv4;
      birdSocket = "/var/run/bird/bird.ctl";
    };
  };

  systemd.services.bird-lgproxy-go = {
    enable = builtins.elem LT.tags.server LT.this.tags;
    description = "Bird-lgproxy-go";
    wantedBy = ["multi-user.target"];
    path = with pkgs; [
      # mtr
      traceroute
    ];
    environment = {
      BIRD_SOCKET = "/run/bird/bird.ctl";
      BIRDLG_LISTEN = "${LT.this.ltnet.IPv4}:8000";
    };
    unitConfig = {
      After = "bird2.service";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.bird-lgproxy-go}/bin/proxy";

        # Needed by mtr and traceroute
        AmbientCapabilities = ["CAP_NET_ADMIN" "CAP_NET_RAW"];
        CapabilityBoundingSet = ["CAP_NET_ADMIN" "CAP_NET_RAW"];
        SystemCallFilter = [];

        Group = "bird2";
        User = "bird2";

        CPUQuota = "10%";
      };
  };
}
