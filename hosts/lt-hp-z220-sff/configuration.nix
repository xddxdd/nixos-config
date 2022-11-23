{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  imports = [
    ../../nixos/none.nix

    ./hardware-configuration.nix
    ./media-center.nix

    ../../nixos/client-components/network-manager.nix
    ../../nixos/client-components/tlp.nix

    ../../nixos/optional-apps/flexget.nix
    ../../nixos/optional-apps/ksmbd.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/resilio.nix
  ];

  boot.kernelParams = [ "pci=realloc,assign-busses" ];

  # ECC RAM
  hardware.rasdaemon.enable = true;

  # Handle multiple NICs
  networking.usePredictableInterfaceNames = lib.mkForce true;

  services.beesd.filesystems.root = {
    spec = "/nix";
    hashTableSizeMB = 32;
    verbosity = "crit";
  };

  services.beesd.filesystems.storage = {
    spec = "/mnt/storage";
    hashTableSizeMB = 2048;
    verbosity = "crit";
  };

  services.fwupd.enable = true;

  services.ksmbd = {
    enable = true;
    shares = {
      "storage" = {
        "path" = "/mnt/storage";
        "read only" = false;
        "force user" = "lantian";
        "force group" = "users";
        "valid users" = "lantian";
      };
    };
  };

  services.resilio.directoryRoot = lib.mkForce "/mnt/storage/media";

  services.tlp.settings = {
    TLP_PERSISTENT_DEFAULT = 1;
    
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];
}
