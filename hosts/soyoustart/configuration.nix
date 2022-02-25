{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/asf.nix
    ../../nixos/optional-apps/drone-ci.nix
    ../../nixos/optional-apps/hath.nix
    ../../nixos/optional-apps/nextcloud.nix
    ../../nixos/optional-apps/nginx-ssltest.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/tg-bot-cleaner-bot.nix
    ../../nixos/optional-apps/xmrig.nix
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

  services.yggdrasil.config.Peers = LT.yggdrasil [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];

  services.ftp-proxy = {
    enable = true;
    target = "ftpback-rbx2-162.ovh.net";
  };
}
