{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  # rage crashes on this node
  age.ageBin = "${pkgs.age}/bin/age";

  systemd.network.networks.eth0 = {
    address = [ "23.226.61.104/27" ];
    gateway = [ "23.226.61.97" ];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

}
