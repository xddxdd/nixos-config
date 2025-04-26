{ config, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
  ];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 32;
    verbosity = "crit";
    extraOptions = [
      "--loadavg-target"
      "4"
    ];
  };

  systemd.network.networks.eth0 = {
    address = [ "192.168.1.14/24" ];
    gateway = [ "192.168.1.1" ];
    matchConfig.Name = "eth0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::14";
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
