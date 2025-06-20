{ LT, inputs, ... }:
{
  imports = [
    ../../nixos/server.nix

    (inputs.secrets + "/dn42/oracle-vm1.nix")

    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  systemd.network.networks.eth0 = LT.cloudLanNetworking "eth0";

  services."route-chain" = {
    enable = true;
    routes = [ "172.22.76.97/29" ];
  };

  # services.openiscsi = {
  #   enable = true;
  #   name = "iqn.2020-08.org.linux-iscsi.initiatorhost:${config.networking.hostName}";
  # };
}
