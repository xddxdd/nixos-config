{ pkgs, lib, config, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  anycast = import ./anycast.nix { inherit config pkgs lib; };
  dn42 = import ./dn42.nix { inherit config pkgs lib; };
  ltnet = import ./ltnet.nix { inherit config pkgs lib; };
  sys = import ./sys.nix { inherit config pkgs lib; };
in
{
  services.bird2 = {
    enable = true;
    checkConfig = false;
    config = builtins.concatStringsSep "\n" ([
      sys.common
      sys.network
      sys.static
      sys.kernel
      anycast.babel

    ] ++ lib.optionals (LT.this.role == LT.roles.server) [
      sys.roa
      sys.roaMonitor

      dn42.communityFilters
      dn42.common
      dn42.peers
      (lib.optionalString (dn42.hasPeers) dn42.grc)

    ] ++ lib.optionals (!LT.this.ltnet.alone) [
      ltnet.common
      ltnet.dynamic
      ltnet.peers
    ]);
  };

  systemd.tmpfiles.rules = [
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa4.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa6.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa4.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa6.conf 644 root root - # placebo"
  ];

  services.prometheus.exporters = {
    bird = {
      enable = true;
      port = LT.port.Prometheus.BirdExporter;
      listenAddress = LT.this.ltnet.IPv4;
      birdSocket = "/var/run/bird/bird.ctl";
    };
  };

  systemd.services.bird-lgproxy-go = {
    description = "Bird-lgproxy-go";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.traceroute ];
    environment = {
      BIRD_SOCKET = "/run/bird/bird.ctl";
      BIRDLG_LISTEN = "${LT.this.ltnet.IPv4}:8000";
    };
    unitConfig = {
      After = "bird2.service";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.bird-lgproxy-go}/bin/proxy";

      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      Group = "bird2";
      User = "bird2";
    };
  };
}
