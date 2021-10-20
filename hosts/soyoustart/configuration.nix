{ config, pkgs, ... }:

{
  imports = [
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

    ../../common/apps/asf.nix
    ../../common/apps/drone-ci.nix
    ../../common/apps/hath.nix
    ../../common/apps/tg-bot-cleaner-bot.nix
    ../../common/apps/xmrig.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    efiSupport = true;
    mirroredBoots = [
      { devices = [ "nodev" ]; path = "/boot/esp0"; }
      { devices = [ "nodev" ]; path = "/boot/esp1"; }
      { devices = [ "nodev" ]; path = "/boot/esp2"; }
      { devices = [ "nodev" ]; path = "/boot/esp3"; }
    ];
  };
  boot.loader.efi.efiSysMountPoint = "/boot/EFI";

  boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_xanmod;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = pkgs.lib.mkForce 0;
    "net.ipv4.conf.default.rp_filter" = pkgs.lib.mkForce 0;
    "net.ipv6.conf.all.autoconf" = pkgs.lib.mkForce 0;
    "net.ipv6.conf.all.accept_ra" = pkgs.lib.mkForce 0;
  };

  networking.hostName = "soyoustart"; # Define your hostname.
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "51.77.66.117";
        prefixLength = 24;
      }
    ];
    ipv6.addresses = [
      {
        address = "2001:41d0:700:2475::1";
        prefixLength = 64;
      }
    ];
  };
  networking.defaultGateway = {
    address = "51.77.66.254";
  };
  networking.defaultGateway6 = {
    address = "2001:41d0:700:24FF:FF:FF:FF:FF";
    interface = "eth0";
  };
  networking.nameservers = [
    "8.8.8.8"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  lantian.enable-php = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
