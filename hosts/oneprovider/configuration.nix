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

    ../../nixos/optional-apps/asf.nix
    ../../nixos/optional-apps/asterisk
    ../../nixos/optional-apps/bird-lg-go.nix
    ../../nixos/optional-apps/drone-ci.nix
    ../../nixos/optional-apps/gitea.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/grafana.nix
    ../../nixos/optional-apps/konnect
    ../../nixos/optional-apps/matrix-synapse.nix
    ../../nixos/optional-apps/miniflux.nix
    ../../nixos/optional-apps/mysql.nix
    ../../nixos/optional-apps/nextcloud.nix
    ../../nixos/optional-apps/nginx-lab
    ../../nixos/optional-apps/plausible
    ../../nixos/optional-apps/prometheus.nix
    ../../nixos/optional-apps/quassel.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/sftp-server.nix
    ../../nixos/optional-apps/tg-bot-cleaner-bot
    ../../nixos/optional-apps/vaultwarden.nix
    ../../nixos/optional-apps/vlmcsd.nix
    ../../nixos/optional-apps/waline.nix
    ../../nixos/optional-apps/yourls.nix

    ../../nixos/optional-cron-jobs/ssl-certs.nix
    ../../nixos/optional-cron-jobs/testssl.nix
  ];

  boot.initrd.systemd.enable = lib.mkForce false;

  # ECC RAM
  hardware.rasdaemon.enable = true;

  systemd.network.networks.eth0 = {
    address = ["51.159.15.98/24"];
    gateway = ["51.159.15.1"];
    matchConfig.Name = "eth0";
    networkConfig = {
      IPv6AcceptRA = false;
      Tunnel = "henet";
    };
  };

  systemd.network.netdevs.henet = {
    netdevConfig = {
      Kind = "sit";
      Name = "henet";
    };
    tunnelConfig = {
      Local = LT.this.public.IPv4;
      Remote = "216.66.84.42";
      TTL = 255;
    };
  };

  systemd.network.networks.henet = {
    address = [
      "2001:470:1f12:3b1::2/64"
      "2001:470:1f13:3b1::1/64"
      "2001:470:cab6::1/48"
    ];
    gateway = ["2001:470:1f12:3b1::1"];
    matchConfig.Name = "henet";
  };

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 1024;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  services.beesd.filesystems.storage = {
    spec = config.fileSystems."/mnt/storage".device;
    hashTableSizeMB = 2048;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  services.resilio.directoryRoot = lib.mkForce "/mnt/storage/media";

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
