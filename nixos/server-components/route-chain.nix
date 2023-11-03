{
  pkgs,
  lib,
  LT,
  config,
  options,
  utils,
  inputs,
  ...
} @ args: {
  options.services."route-chain" = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable route-chain service.";
    };
    routes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Routes to be handled by route-chain.";
    };
  };

  config.systemd.services.route-chain = {
    inherit (config.services."route-chain") enable;
    description = "Route Chain";
    wantedBy = ["multi-user.target"];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.route-chain}/bin/route-chain ${builtins.concatStringsSep " " config.services."route-chain".routes}";

        AmbientCapabilities = ["CAP_NET_ADMIN"];
        CapabilityBoundingSet = ["CAP_NET_ADMIN"];
        DynamicUser = true;

        PrivateDevices = false;
        ProtectClock = false;
        ProtectControlGroups = false;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_NETLINK"];
      };
  };
}
