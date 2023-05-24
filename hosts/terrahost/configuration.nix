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
  ];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 16;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "1"];
  };

  systemd.network.networks.eth0 = {
    address = ["194.32.107.228/24" "2a03:94e0:ffff:194:32:107::228/118" "2a03:94e0:27ca::1/48"];
    gateway = ["194.32.107.1" "2a03:94e0:ffff:194:32:107::1"];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
