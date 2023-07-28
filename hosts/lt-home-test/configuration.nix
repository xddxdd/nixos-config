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

    ../../nixos/client-components/tlp.nix

    ../../nixos/server-components/backup.nix
    ../../nixos/server-components/logging.nix

    ../../nixos/optional-apps/vlmcsd.nix
  ];

  boot.kernelParams = ["pci=realloc,assign-busses"];

  # ECC RAM
  hardware.rasdaemon.enable = true;

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 32;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  # Rename to LAN to apply correct firewall rules
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{device/vendor}=="0x1af4", ATTR{device/device}=="0x0001",NAME="lan0"
  '';

  systemd.network.networks.lan0 = {
    address = ["192.168.1.13/24"];
    gateway = ["192.168.1.1"];
    matchConfig.Name = "lan0";
  };

  services.fwupd.enable = true;

  services.tlp.settings = lib.mapAttrs (n: lib.mkForce) {
    TLP_DEFAULT_MODE = "BAT";
    TLP_PERSISTENT_DEFAULT = 1;
  };
}
