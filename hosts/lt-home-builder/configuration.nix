{ ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ../../nixos/server-components/backup.nix
    ../../nixos/optional-apps/attic-watch-store.nix
    ../../nixos/optional-apps/hydra

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "192.168.1.12/24" ];
    gateway = [ "192.168.1.1" ];
    matchConfig.Name = "eth0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::12";
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
