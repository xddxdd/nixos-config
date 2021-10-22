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
  ];

  nixpkgs.localSystem = { config = "aarch64-unknown-linux-gnu"; system = "aarch64-linux"; };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;

  networking.hostName = "oracle-vm-arm"; # Define your hostname.
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "172.18.126.4";
        prefixLength = 24;
      }
    ];
    ipv6.addresses = [
      {
        address = "2603:c021:8000:aaaa:4::1";
        prefixLength = 64;
      }
    ];
  };
  networking.defaultGateway = {
    address = "172.18.126.1";
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
