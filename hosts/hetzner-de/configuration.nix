{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/attic.nix
    ../../nixos/optional-apps/bepasty.nix
    ../../nixos/optional-apps/bird-lg-go.nix
    ../../nixos/optional-apps/drone-ci.nix
    ../../nixos/optional-apps/gitea.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/grafana.nix
    ../../nixos/optional-apps/keycloak
    ../../nixos/optional-apps/lemmy.nix
    ../../nixos/optional-apps/matrix-synapse.nix
    ../../nixos/optional-apps/miniflux.nix
    ../../nixos/optional-apps/mysql.nix
    ../../nixos/optional-apps/nextcloud.nix
    ../../nixos/optional-apps/nginx-lab
    ../../nixos/optional-apps/nginx-private.nix
    ../../nixos/optional-apps/plausible
    ../../nixos/optional-apps/prometheus.nix
    ../../nixos/optional-apps/quassel.nix
    ../../nixos/optional-apps/rsshub.nix
    ../../nixos/optional-apps/step-ca.nix
    ../../nixos/optional-apps/tg-bot-cleaner-bot
    ../../nixos/optional-apps/vaultwarden.nix
    ../../nixos/optional-apps/waline.nix
    ../../nixos/optional-apps/yourls.nix

    ../../nixos/optional-cron-jobs/ssl-certs.nix
    ../../nixos/optional-cron-jobs/testssl.nix

    "${inputs.secrets}/nixos-hidden-module/ca877276fe06bd79"
  ];

  systemd.network.networks.eth0 = {
    address = ["142.132.236.113/24" "2a01:4f8:c012:6530::1/64"];
    matchConfig.Name = "eth0";
    networkConfig = {
      IPv6AcceptRA = false;
    };
    routes = [
      {
        routeConfig = {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        };
      }
      {
        routeConfig = {
          Gateway = "fe80::1";
          GatewayOnLink = true;
        };
      }
    ];
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
