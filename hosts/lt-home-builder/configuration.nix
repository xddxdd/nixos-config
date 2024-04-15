{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
  ];

  # Rename to LAN to apply correct firewall rules
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{device/vendor}=="0x1af4", ATTR{device/device}=="0x0001",NAME="lan0"
  '';

  systemd.network.networks.lan0 = {
    address = [
      "192.168.1.12/24"
      "fc00:192:168:1::12/64"
    ];
    gateway = [
      "192.168.1.1"
      "fc00:192:168:1::1"
    ];
    matchConfig.Name = "lan0";
  };
}
