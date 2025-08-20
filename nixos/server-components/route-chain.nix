{
  pkgs,
  lib,
  LT,
  config,
  options,
  ...
}:
{
  options.services."route-chain" = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable route-chain service.";
    };
    routes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Routes to be handled by route-chain.";
    };
  };

  config.systemd.services.route-chain = {
    inherit (config.services."route-chain") enable;
    description = "Route Chain";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = LT.networkToolHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur-xddxdd.route-chain}/bin/route-chain ${
        builtins.concatStringsSep " " config.services."route-chain".routes
      }";
      DynamicUser = true;
    };
  };
}
