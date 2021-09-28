# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common/apps/ltnet.nix
      ../../common/apps/tinc.nix
      ../../common/apps/babeld.nix
      ../../common/apps/bird.nix
    ];

  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "virmach-nl1g"; # Define your hostname.
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "172.245.52.105";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = {
    address = "172.245.52.1";
  };
  networking.nameservers = [
    "1.1.1.1"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
