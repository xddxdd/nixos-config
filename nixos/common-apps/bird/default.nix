{ pkgs, config, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  dn42 = import ./dn42.nix { inherit config pkgs; };
  ltnet = import ./ltnet.nix { inherit config pkgs; };
  sys = import ./sys.nix { inherit config pkgs; };
in
{
  services.bird2 = {
    enable = true;
    checkConfig = false;
    config = builtins.concatStringsSep "\n" [
      sys.common
      sys.network
      sys.static
      sys.roa
      sys.roaMonitor
      sys.kernel
      dn42.communityFilters
      dn42.common
      dn42.peers
      (pkgs.lib.optionalString (LT.this.dn42.peerWithGRC or false) dn42.grc)
      ltnet.docker
      (pkgs.lib.optionalString (!(LT.this.ltnet.alone or false)) ltnet.common)
      (pkgs.lib.optionalString (!(LT.this.ltnet.alone or false)) ltnet.peers)
    ];
  };

  systemd.tmpfiles.rules = [
    "f /var/lib/bird/dn42/dn42_bird2_roa4.conf 644 root root - # placebo"
    "f /var/lib/bird/dn42/dn42_bird2_roa6.conf 644 root root - # placebo"
    "f /var/lib/bird/neonetwork/neonetwork_bird2_roa4.conf 644 root root - # placebo"
    "f /var/lib/bird/neonetwork/neonetwork_bird2_roa6.conf 644 root root - # placebo"
  ];

  services.prometheus.exporters = {
    bird = {
      enable = true;
      port = LT.port.Prometheus.BirdExporter;
      listenAddress = LT.this.ltnet.IPv4;
    };
  };

  systemd.services.bird2 = {
    bindsTo = [ "tinc.ltmesh.service" ];
    serviceConfig.CPUQuota = "10%";
  };

  systemd.services.bird-lgproxy-go = {
    description = "Bird-lgproxy-go";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.traceroute ];
    environment = {
      BIRD_SOCKET = "/run/bird.ctl";
      BIRD6_SOCKET = "/run/bird.ctl";
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
