{ LT, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  systemd.network.networks.eth0 = LT.cloudLanNetworking "eth0";

  # services.openiscsi = {
  #   enable = true;
  #   name = "iqn.2020-08.org.linux-iscsi.initiatorhost:${config.networking.hostName}";
  # };
}
