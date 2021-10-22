{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
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

  networking.hostName = "50kvm"; # Define your hostname.
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "23.226.61.104";
        prefixLength = 27;
      }
    ];
  };
  networking.defaultGateway = {
    address = "23.226.61.97";
  };
  networking.nameservers = [
    "1.1.1.1"
  ];

  networking.sits.henet = {
    remote = "216.218.221.6";
    local = thisHost.public.IPv4;
    dev = "eth0";
    ttl = 255;
  };
  networking.interfaces.henet = {
    ipv6.addresses = [
      {
        address = "2001:470:18:10bd::2";
        prefixLength = 64;
      }
      {
        address = "2001:470:19:10bd::1";
        prefixLength = 64;
      }
      {
        address = "2001:470:fa1d::1";
        prefixLength = 48;
      }
    ];
  };
  networking.defaultGateway6 = {
    address = "2001:470:18:10bd::1";
  };

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
