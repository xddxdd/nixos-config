{ ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/asterisk

    ../../nixos/optional-cron-jobs/auto-mihoyo-bbs
    ../../nixos/optional-cron-jobs/bilibili-tool-pro.nix
  ];

  systemd.network.networks.eth0 = {
    address = [
      "23.145.48.11/24"
      "2605:3a40:4::142/64"
    ];
    gateway = [
      "23.145.48.1"
      "2605:3a40:4::1"
    ];
    matchConfig.Name = "eth0";
  };
}
