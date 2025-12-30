{
  inputs,
  config,
  lib,
  LT,
  ...
}:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/acme
    ../../nixos/optional-apps/attic.nix
    ../../nixos/optional-apps/bepasty.nix
    ../../nixos/optional-apps/bird-lg-go.nix
    ../../nixos/optional-apps/byparr.nix
    ../../nixos/optional-apps/dex.nix
    ../../nixos/optional-apps/flapalerted.nix
    ../../nixos/optional-apps/gitea-actions.nix
    ../../nixos/optional-apps/gitea.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/lemmy.nix
    ../../nixos/optional-apps/matrix-synapse
    ../../nixos/optional-apps/miniflux.nix
    ../../nixos/optional-apps/netbox.nix
    ../../nixos/optional-apps/plausible
    ../../nixos/optional-apps/pocket-id.nix
    ../../nixos/optional-apps/quassel.nix
    ../../nixos/optional-apps/radicale.nix
    ../../nixos/optional-apps/rsshub.nix
    ../../nixos/optional-apps/rsync-server-ci.nix
    ../../nixos/optional-apps/syncthing.nix
    ../../nixos/optional-apps/waline
    ../../nixos/optional-apps/yggdrasil-alfis.nix
    ../../nixos/optional-apps/zerotierone-controller

    ../../nixos/optional-cron-jobs/cleanup-github-notifications
    ../../nixos/optional-cron-jobs/dn42-certificate.nix
    ../../nixos/optional-cron-jobs/radicale-calendar-sync.nix
    ../../nixos/optional-cron-jobs/testssl.nix

    "${inputs.secrets}/nixos-hidden-module/11116c7374949a7a"
    "${inputs.secrets}/nixos-hidden-module/35c68fea6f2bde77"
    "${inputs.secrets}/nixos-hidden-module/c9f6c0c333e73062"
    "${inputs.secrets}/nixos-hidden-module/ca877276fe06bd79"
  ];

  systemd.network.networks.eth1 = {
    address = [ "23.94.65.218/30" ];
    gateway = [ "23.94.65.217" ];
    matchConfig.Name = "eth1";
  };

  networking.henet = {
    enable = true;
    remote = "209.51.161.14";
    addresses = [
      "2001:470:1f06:6fe::2/64"
      "2001:470:1f07:6fe::1/64"
      "2001:470:8c19::1/48"
    ];
    gateway = "2001:470:1f06:6fe::1";
    attachToInterface = "eth1";
  };

  virtualisation.oci-containers.containers.byparr.ports = [
    "${LT.this.ltnet.IPv4}:${LT.portStr.FlareSolverr}:8191"
  ];
  systemd.services.flaresolverr = lib.mkIf config.services.flaresolverr.enable {
    environment.HOST = lib.mkForce LT.this.ltnet.IPv4;
  };
}
