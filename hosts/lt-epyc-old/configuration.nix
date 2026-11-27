{ ... }:
{
  imports = [
    ../../nixos/common-apps/nginx
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
    ./openvswitch.nix
    ./fan-control

    ../../nixos/optional-apps/comfyui
    ../../nixos/optional-apps/llama-cpp.nix
    ../../nixos/optional-apps/llama-swap
  ];

  # P4 left out of Maya: 8 GB, 65 W, and the decode is bound by expert
  # transfers rather than by the third card
  lantian.maya.gpus = "0,2";

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
