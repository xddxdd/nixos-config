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
    ../../common/apps/resilio.nix
    ../../common/apps/tg-bot-cleaner-bot.nix
    ../../common/apps/xmrig.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "51.77.66.117/24" "2001:41d0:700:2475::1/64" ];
    gateway = [ "51.77.66.254" ];
    routes = [{
      # Special config since gateway isn't in subnet
      routeConfig = {
        Gateway = "2001:41d0:700:24ff:ff:ff:ff:ff";
        GatewayOnLink = true;
      };
    }];
    matchConfig.Name = "eth0";
  };

  networking.nameservers = [
    "172.18.0.253"
    "8.8.8.8"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:41d0:700:2475::1/120"
    ];
  };

  lantian.enable-php = true;

  services.beesd.filesystems.root = {
    spec = "/";
    hashTableSizeMB = 4096;
    verbosity = "crit";
    extraOptions = [ "--thread-count" "2" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
