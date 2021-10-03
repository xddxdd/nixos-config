{ pkgs, config, options, ... }:

{
  options.services."route-chain" = {
    enable = pkgs.lib.mkOption {
      type = pkgs.lib.types.bool;
      default = false;
      description = "Enable route-chain service.";
    };
    routes = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf pkgs.lib.types.string;
      default = [];
      description = "Routes to be handled by route-chain.";
    };
  };

  config.systemd.services.route-chain = {
    enable = config.services."route-chain".enable;
    description = "Route Chain";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur.repos.xddxdd.route-chain}/bin/route-chain ${builtins.concatStringsSep " " config.services."route-chain".routes}";
    };
  };
}
