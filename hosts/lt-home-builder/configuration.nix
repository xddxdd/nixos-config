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
    ../../nixos/none.nix

    ./hardware-configuration.nix

    # Disabled for disk space concerns
    # ../../nixos/optional-cron-jobs/rebuild-nixos-config.nix
  ];

  # Rename to LAN to apply correct firewall rules
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{device/vendor}=="0x1af4", ATTR{device/device}=="0x0001",NAME="lan0"
  '';

  systemd.network.networks.lan0 = {
    address = ["192.168.0.12/24"];
    gateway = ["192.168.0.1"];
    matchConfig.Name = "lan0";
  };
}
