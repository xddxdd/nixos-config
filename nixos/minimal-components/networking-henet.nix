{
  config,
  lib,
  LT,
  ...
}:
let
  cfg = config.networking.henet;
in
{
  options.networking.henet = {
    enable = lib.mkEnableOption "HE.net IPv6 tunnel";

    remote = lib.mkOption {
      type = lib.types.str;
      description = "Remote tunnel endpoint IP address";
    };

    addresses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "IPv6 addresses for the tunnel interface";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      description = "IPv6 gateway address";
    };

    mtu = lib.mkOption {
      type = lib.types.str;
      default = "1480";
      description = "MTU bytes for the tunnel interface";
    };

    attachToInterface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "Network interface to attach the tunnel to";
    };

    sourceSpecificRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Source ranges for routes";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.network.netdevs.henet = {
      netdevConfig = {
        Kind = "sit";
        Name = "henet";
        MTUBytes = cfg.mtu;
      };
      tunnelConfig = {
        Local = LT.this.public.IPv4;
        Remote = cfg.remote;
        TTL = 255;
      };
    };

    systemd.network.networks = {
      henet = {
        address = cfg.addresses;
        gateway = lib.optionals (cfg.sourceSpecificRoutes == [ ]) [ cfg.gateway ];
        matchConfig.Name = "henet";
        routes = lib.optionals (cfg.sourceSpecificRoutes != [ ]) (
          builtins.map (s: {
            Gateway = cfg.gateway;
            Source = s;
          }) cfg.sourceSpecificRoutes
        );
      };
      ${cfg.attachToInterface}.networkConfig.Tunnel = "henet";
    };
  };
}
