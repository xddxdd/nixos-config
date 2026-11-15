{ ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
    ./openvswitch.nix
  ];

  systemd.network.networks.br0 = {
    address = [
      "192.168.0.7/24"
      "2001:470:e997::7/64"
    ];
    gateway = [
      "192.168.0.1"
      "2001:470:e997::1"
    ];
    matchConfig.Name = "br0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "no";
  };
}
