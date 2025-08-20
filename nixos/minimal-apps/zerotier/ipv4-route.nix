{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.lantian.ipv4TrafficRouteHost = lib.mkOption {
    type = lib.types.nullOr lib.types.attrs;
    default = null;
    description = "Host to route IPv4 traffic to";
  };

  config = lib.mkIf (config.lantian.ipv4TrafficRouteHost != null) {
    systemd.services.zerotierone = {
      path = [ pkgs.iproute2 ];
      postStart = ''
        while ! ip addr show ztje7axwd2 | grep 198.18.0; do
          echo "Waiting for ZeroTier to setup IPv4"
          sleep 1
        done
        ip route add default via ${config.lantian.ipv4TrafficRouteHost.ltnet.IPv4} dev ztje7axwd2
      '';
    };
  };
}
