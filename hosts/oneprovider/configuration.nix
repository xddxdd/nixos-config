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
    ../../nixos/optional-apps/mysql.nix
    ../../nixos/optional-apps/nextcloud.nix
    ../../nixos/optional-apps/nginx-lab
    ../../nixos/optional-apps/plausible
    ../../nixos/optional-apps/prometheus.nix
    ../../nixos/optional-apps/quassel.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/sftp-server.nix
    ../../nixos/optional-apps/tg-bot-cleaner-bot
    ../../nixos/optional-apps/transmission-daemon.nix
    ../../nixos/optional-apps/vaultwarden.nix
    ../../nixos/optional-apps/waline.nix
    ../../nixos/optional-apps/yggdrasil-alfis.nix
  ];

  services.beesd.filesystems.root = {
    spec = "/nix";
    hashTableSizeMB = 1024;
    verbosity = "crit";
  };

  systemd.network.networks.eth0 = {
    address = [ "51.159.15.98/24" "2001:0bc8:1201:0706:8634:97ff:fe11:7b94/64" ];
    gateway = [ "51.159.15.1" ];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  services.yggdrasil.regions = [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];
}
