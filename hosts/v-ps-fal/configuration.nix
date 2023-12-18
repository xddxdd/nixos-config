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
    ../../nixos/optional-apps/calibre-cops.nix
    ../../nixos/optional-apps/drone-ci.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/keycloak
    ../../nixos/optional-apps/lemmy.nix
    ../../nixos/optional-apps/matrix-synapse.nix
    ../../nixos/optional-apps/miniflux.nix
    ../../nixos/optional-apps/netbox.nix
    ../../nixos/optional-apps/nginx-private.nix
    ../../nixos/optional-apps/plausible
    ../../nixos/optional-apps/quassel.nix
    ../../nixos/optional-apps/rsshub.nix
    ../../nixos/optional-apps/step-ca.nix
    ../../nixos/optional-apps/tg-bot-cleaner-bot
    ../../nixos/optional-apps/waline.nix

    ../../nixos/optional-cron-jobs/ssl-certs.nix
    ../../nixos/optional-cron-jobs/testssl.nix

    "${inputs.secrets}/nixos-hidden-module/11116c7374949a7a"
    "${inputs.secrets}/nixos-hidden-module/35c68fea6f2bde77"
    "${inputs.secrets}/nixos-hidden-module/ca877276fe06bd79"
  ];

  systemd.network.networks.eth0 = {
    address = ["185.254.74.105/24" "2a03:d9c0:2000::72/48"];
    gateway = ["185.254.74.1" "2a03:d9c0:2000::1"];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
