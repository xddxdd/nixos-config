{ lib, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    # ../../nixos/optional-apps/lancache.nix

    ./hardware-configuration.nix
  ];

  networking.nameservers = lib.mkForce [ "192.168.0.1" ];

  # services.lancache.environment = {

  # };

  systemd.network.networks.eth0 = {
    address = [ "192.168.0.4/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "eth0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::4";
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
