{
  pkgs,
  lib,
  LT,
  ...
}:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "2a14:67c0:306:211::a/128" ];
    routes = [
      {
        # Special config since gateway isn't in subnet
        Gateway = "2a14:67c0:306::1";
        GatewayOnLink = true;
      }
    ];
    matchConfig.Name = "eth0";
  };

  systemd.services.zerotierone = {
    path = [ pkgs.iproute2 ];
    postStart = ''
      while ! ip addr show ztje7axwd2 | grep 198.18.0; do
        echo "Waiting for ZeroTier to setup IPv4"
        sleep 1
      done
      ip route add default via ${LT.hosts.v-ps-hkg.ltnet.IPv4} dev ztje7axwd2
    '';
  };

  # Cannot connect to log server since this server is IPv6 only
  services.filebeat.enable = lib.mkForce false;

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
