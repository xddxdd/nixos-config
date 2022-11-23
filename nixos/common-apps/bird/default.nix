{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;

  anycast = import ./anycast.nix args;
  dn42 = import ./dn42.nix args;
  ltnet = import ./ltnet.nix args;
  sys = import ./sys.nix args;
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

      # Used by ltnet
      dn42.communityFilters

    ] ++ lib.optionals (LT.this.role == LT.roles.server) [
      sys.roa
      sys.roaMonitor

      dn42.common
      dn42.peers
      (lib.optionalString dn42.hasPeers dn42.grc)

    ] ++ lib.optionals (!LT.this.ltnet.alone) [
      ltnet.common
      ltnet.dynamic
      ltnet.peers
    ]);
  };

  systemd.services.bird2.serviceConfig = {
    CPUQuota = "10%";
    Restart = lib.mkForce "always";
  };

  systemd.tmpfiles.rules = [
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa4.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa6.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa4.conf 644 root root - # placebo"
    "f /nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa6.conf 644 root root - # placebo"
  ];

  services.prometheus.exporters = {
    bird = {
      enable = LT.this.role == LT.roles.server;
      port = LT.port.Prometheus.BirdExporter;
      listenAddress = LT.this.ltnet.IPv4;
      birdSocket = "/var/run/bird/bird.ctl";
    };
  };

  systemd.services.bird-lgproxy-go = {
    enable = LT.this.role == LT.roles.server;
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
