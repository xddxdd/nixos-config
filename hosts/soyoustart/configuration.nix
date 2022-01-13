{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../common/apps/acme-sh.nix
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
    ../../common/apps/yggdrasil.nix
    ../../common/apps/zsh.nix

    ../../common/apps/asf.nix
    ../../common/apps/drone-ci.nix
    ../../common/apps/hath.nix
    ../../common/apps/nginx-ssltest.nix
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
    spec = "/nix";
    hashTableSizeMB = 4096;
    verbosity = "crit";
    extraOptions = [ "--thread-count" "2" ];
  };

  services.yggdrasil.config.Peers =
    let
      publicPeers = import ../../common/helpers/yggdrasil/public-peers.nix { inherit pkgs; };
    in
    publicPeers [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];

  services.ftp-proxy = {
    enable = true;
    target = "ftpback-rbx2-162.ovh.net";
  };
}
