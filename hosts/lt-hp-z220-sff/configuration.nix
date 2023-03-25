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
    ./media-center.nix
    ./networking.nix
    ./shares.nix

    ../../nixos/hardware/ignore-nice-load.nix

    ../../nixos/client-components/cups.nix

    ../../nixos/server-components/backup.nix
    ../../nixos/server-components/logging.nix

    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/miniupnpd.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/sftp-server.nix
    ../../nixos/optional-apps/vlmcsd.nix
  ];

  boot.initrd.systemd.enable = lib.mkForce false;
  boot.kernelParams = ["pci=realloc,assign-busses"];

  # ECC RAM
  hardware.rasdaemon.enable = true;

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 32;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  services.beesd.filesystems.storage = {
    spec = config.fileSystems."/mnt/storage".device;
    hashTableSizeMB = 2048;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  services.avahi.enable = lib.mkForce true;
  services.printing = {
    browsing = true;
    defaultShared = true;
    listenAddresses = ["127.0.0.1:631" "192.168.0.2:631"];
    allowFrom = ["all"];
  };

  services.fwupd.enable = true;

  services.tlp.settings = {
    TLP_DEFAULT_MODE = "BAT";
    TLP_PERSISTENT_DEFAULT = 1;
  };
}
