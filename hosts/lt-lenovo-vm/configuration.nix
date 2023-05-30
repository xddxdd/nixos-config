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

    ../../nixos/optional-apps/resilio.nix
  ];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 16;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  services.beesd.filesystems.storage = {
    spec = config.fileSystems."/mnt/storage".device;
    hashTableSizeMB = 128;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  systemd.network.networks.eth0 = {
    address = ["198.19.102.10/24"];
    gateway = ["198.19.102.1"];
    matchConfig.Name = "eth0";
  };

  lantian.resilio.storage = "/mnt/storage/media";

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
