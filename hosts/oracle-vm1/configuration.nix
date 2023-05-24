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

    ./dn42.nix
    ./hardware-configuration.nix
  ];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 16;
    verbosity = "crit";
    extraOptions = ["--thread-count" "1" "--loadavg-target" "1"];
  };

  systemd.network.networks.eth0 = {
    address = ["172.18.126.2/24"];
    gateway = ["172.18.126.1"];
    networkConfig.DHCP = "ipv6";
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  # services.openiscsi = {
  #   enable = true;
  #   name = "iqn.2020-08.org.linux-iscsi.initiatorhost:${config.networking.hostName}";
  # };
}
