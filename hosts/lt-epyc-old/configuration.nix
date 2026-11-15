{ ... }:
{
  imports = [
    ../../nixos/common-apps/nginx
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
    ./openvswitch.nix
    ./fan-control

    ../../nixos/optional-apps/llama-cpp.nix
    # ../../nixos/optional-apps/llama-swap
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
