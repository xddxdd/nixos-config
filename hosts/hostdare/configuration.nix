{ config, pkgs, ... }:

{
  imports = [
    ./dn42.nix
    ./hardware-configuration.nix

    ../../common/apps/ansible.nix
    ../../common/apps/babeld.nix
    ../../common/apps/bird.nix
    ../../common/apps/coredns.nix
    ../../common/apps/ltnet.nix
    ../../common/apps/nginx-proxy.nix
    ../../common/apps/nginx.nix
    ../../common/apps/powerdns-recursor.nix
    ../../common/apps/qemu-user-static.nix
    ../../common/apps/tinc.nix
    ../../common/apps/v2ray.nix
    ../../common/apps/zsh.nix
  ];

  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "hostdare"; # Define your hostname.
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "185.186.147.110";
        prefixLength = 23;
      }
    ];
    ipv6.addresses = [
      {
        address = "2607:fcd0:100:b100:0000:0000:198a:b7f6";
        prefixLength = 64;
      }
    ];
  };
  networking.defaultGateway = {
    address = "185.186.146.1";
  };
  networking.defaultGateway6 = {
    address = "2607:fcd0:100:b100::1";
  };
  networking.nameservers = [
    "172.18.0.253"
    "8.8.8.8"
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
