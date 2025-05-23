{ config, lib, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix

    ../../nixos/common-apps/nginx

    ../../nixos/optional-apps/mysql.nix
    ../../nixos/optional-apps/open5gs
  ];

  networking.nameservers = lib.mkForce [ "192.168.0.1" ];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 32;
    verbosity = "crit";
    extraOptions = [
      "--loadavg-target"
      "4"
      "--workaround-btrfs-send"
    ];
  };

  systemd.network.networks.eth0 = {
    address = [ "192.168.0.9/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "eth0";
    # Do not enable Jumbo Frame or this breaks SCTP
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::9";
      DHCPv6Client = "no";
    };
    routes = [
      {
        Destination = "64:ff9b::/96";
        Gateway = "_ipv6ra";
      }
    ];
  };
}
