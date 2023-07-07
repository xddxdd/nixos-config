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

    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/smartrent-auto-lock
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
    SUBSYSTEM=="net", ACTION=="add", ATTR{device/vendor}=="0x8086", ATTR{device/device}=="0x1502",NAME="lan0"
  '';

  systemd.network.networks.lan0 = {
    address = ["192.168.0.3/24"];
    gateway = ["192.168.0.1"];
    matchConfig.Name = "lan0";
  };

  services.fwupd.enable = true;

  services.tlp.settings = lib.mapAttrs (n: lib.mkForce) {
    TLP_DEFAULT_MODE = "BAT";
    TLP_PERSISTENT_DEFAULT = 1;
  };
}
