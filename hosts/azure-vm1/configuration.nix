{ LT, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  # Limit CPU usage to avoid consuming burst credit
  boot.kernelParams = [
    "isolcpus=1"
    "nohz_full=1"
    "rcu_nocbs=1"
  ];

  systemd.network.networks.eth0 = LT.cloudLanNetworking "eth0";

  services."route-chain" = {
    enable = true;
    routes = [ "172.22.76.97/29" ];
  };
}
