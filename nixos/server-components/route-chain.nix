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
      "fdbc:f9dc:67ad:6d61:6e6f:7361:6261::/120"
      "fd10:127:10:6d61:6e6f:7361:6261::/120"
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
      environment.IFNAME = "route-chain";
      unitConfig = {
        After = "network.target";
      };
      serviceConfig = LT.networkToolHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${lib.getExe pkgs.nur-xddxdd.route-chain} ${builtins.concatStringsSep " " config.services.route-chain.routes}";
        DynamicUser = true;
      };
    };
  };
}
