{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../common/apps/babeld.nix
    ../../common/apps/bird.nix
    ../../common/apps/coredns.nix
    ../../common/apps/ltnet.nix
    ../../common/apps/powerdns-recursor.nix
    ../../common/apps/tinc.nix

    ../../common/apps/bird-lg-go.nix
    ../../common/apps/epicgames-claimer.nix
    ../../common/apps/genshin-helper.nix
    ../../common/apps/keycloak.nix
    ../../common/apps/quassel.nix
  ];

  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "virmach-ny6g"; # Define your hostname.
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "107.172.197.108";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = {
    address = "107.172.197.1";
  };
  networking.nameservers = [
    "1.1.1.1"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
