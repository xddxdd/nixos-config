{ pkgs, config, options, ... }:

let
  LT = import ../helpers.nix { inherit config pkgs; };
in
{
  options.services."route-chain" = {
    enable = pkgs.lib.mkOption {
      type = pkgs.lib.types.bool;
      default = false;
      description = "Enable route-chain service.";
    };
    routes = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf pkgs.lib.types.string;
      default = [ ];
      description = "Routes to be handled by route-chain.";
    };
  };

  config.systemd.services.route-chain = {
    enable = config.services."route-chain".enable;
    description = "Route Chain";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.route-chain}/bin/route-chain ${builtins.concatStringsSep " " config.services."route-chain".routes}";

      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      DynamicUser = true;

      PrivateDevices = false;
      ProtectClock = false;
      ProtectControlGroups = false;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" ];

      # Enable @resources
      SystemCallFilter = [
        "@system-service"
        "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @swap"
      ];
    };
  };
}
