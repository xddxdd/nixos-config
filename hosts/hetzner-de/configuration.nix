{ inputs, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/acme
    ../../nixos/optional-apps/bepasty.nix
    ../../nixos/optional-apps/bird-lg-go.nix
    ../../nixos/optional-apps/dex.nix
    ../../nixos/optional-apps/flapalerted.nix
    ../../nixos/optional-apps/gitea-actions.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/lemmy.nix
    ../../nixos/optional-apps/matrix-synapse
    ../../nixos/optional-apps/miniflux.nix
    ../../nixos/optional-apps/netbox.nix
    ../../nixos/optional-apps/nginx-private.nix
    ../../nixos/optional-apps/plausible
    ../../nixos/optional-apps/qinglong.nix
    ../../nixos/optional-apps/quassel.nix
    ../../nixos/optional-apps/radicale.nix
    ../../nixos/optional-apps/rsshub.nix
    ../../nixos/optional-apps/rsync-server-ci.nix
    ../../nixos/optional-apps/tg-bot-cleaner-bot
    ../../nixos/optional-apps/waline
    ../../nixos/optional-apps/yggdrasil-alfis.nix
    ../../nixos/optional-apps/zerotierone-controller

    ../../nixos/optional-cron-jobs/radicale-calendar-sync.nix
    ../../nixos/optional-cron-jobs/testssl.nix

    "${inputs.secrets}/nixos-hidden-module/11116c7374949a7a"
    "${inputs.secrets}/nixos-hidden-module/35c68fea6f2bde77"
    "${inputs.secrets}/nixos-hidden-module/ca877276fe06bd79"
  ];

  systemd.network.networks.eth0 = {
    address = [
      "159.69.30.238/24"
      "2a01:4f8:c2c:8bbf::1/64"
    ];
    matchConfig.Name = "eth0";
    networkConfig = {
      IPv6AcceptRA = false;
    };
    routes = [
      {
        Gateway = "172.31.1.1";
        GatewayOnLink = true;
      }
      {
        Gateway = "fe80::1";
        GatewayOnLink = true;
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
