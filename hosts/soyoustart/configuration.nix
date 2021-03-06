{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/asf.nix
    ../../nixos/optional-apps/asterisk
    ../../nixos/optional-apps/bird-lg-go.nix
    ../../nixos/optional-apps/calibre-cops.nix
    ../../nixos/optional-apps/drone-ci.nix
    ../../nixos/optional-apps/gitea.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/grafana.nix
    ../../nixos/optional-apps/hath.nix
    ../../nixos/optional-apps/konnect
    ../../nixos/optional-apps/matrix-synapse.nix
    ../../nixos/optional-apps/miniflux.nix
    ../../nixos/optional-apps/minio.nix
    ../../nixos/optional-apps/nextcloud.nix
    ../../nixos/optional-apps/nginx-lab.nix
    ../../nixos/optional-apps/plausible
    ../../nixos/optional-apps/prometheus.nix
    ../../nixos/optional-apps/quassel.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/sftp-server.nix
    ../../nixos/optional-apps/tg-bot-cleaner-bot
    ../../nixos/optional-apps/vaultwarden.nix
    ../../nixos/optional-apps/xmrig.nix
    ../../nixos/optional-apps/yggdrasil-alfis.nix
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

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:41d0:700:2475::1/120"
    ];
  };

  services.yggdrasil.regions = [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];

  services.ftp-proxy = {
    enable = true;
    target = "ftpback-rbx2-162.ovh.net";
  };
}
