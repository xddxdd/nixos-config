{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/resilio.nix
  ];

  boot.initrd.systemd.enable = lib.mkForce false;

  systemd.network.networks.eth0 = {
    address = [ "104.152.209.126/24" "2602:ffd5:1:160::1/36" ];
    gateway = [ "104.152.209.1" "2602:ffd5:1:100::1" ];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

}
