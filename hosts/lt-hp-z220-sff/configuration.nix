{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/none.nix

    ./hardware-configuration.nix
    ./media-center.nix
    ./shares.nix

    ../../nixos/client-components/network-manager.nix
    ../../nixos/client-components/tlp.nix

    ../../nixos/optional-apps/flexget.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/sftp-server.nix
  ];

  boot.initrd.systemd.enable = lib.mkForce false;
  boot.kernelParams = [
    "console=ttyS0,115200"
    "pci=realloc,assign-busses"
  ];

  # ECC RAM
  hardware.rasdaemon.enable = true;

  # Handle multiple NICs
  networking.usePredictableInterfaceNames = lib.mkForce true;

  services.beesd.filesystems.root = {
    spec = "/nix";
    hashTableSizeMB = 32;
    verbosity = "crit";
    extraOptions = [ "--loadavg-target" "4" ];
  };

  services.beesd.filesystems.storage = {
    spec = "/mnt/storage";
    hashTableSizeMB = 2048;
    verbosity = "crit";
    extraOptions = [ "--loadavg-target" "4" ];
  };

  services.fwupd.enable = true;

  services.tlp.settings = {
    TLP_PERSISTENT_DEFAULT = 1;
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];

}
