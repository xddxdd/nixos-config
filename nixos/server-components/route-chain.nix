{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  options.services.route-chain = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable route-chain service.";
    };
    routes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Routes to be handled by route-chain.";
    };
  };

  config = {
    services.route-chain.routes = [
      "172.22.76.97/29"
    ]
    ++ lib.optionals config.networking.henet.enable (
      builtins.map (
        v:
        let
          addr = builtins.head (lib.splitString "/" v);
        in
        "${addr}/120"
      ) (builtins.filter (lib.hasInfix "::1/") config.networking.henet.addresses)
    );

    systemd.services.route-chain = {
      inherit (config.services.route-chain) enable;
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
          builtins.concatStringsSep " " config.services.route-chain.routes
        }";
        DynamicUser = true;
      };
    };
  };
}
