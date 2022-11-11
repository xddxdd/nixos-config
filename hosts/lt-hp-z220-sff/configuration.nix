{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  resetKeyboardBacklight = pkgs.writeShellScriptBin "reset-keyboard-backlight" ''
    for F in /sys/devices/platform/hp-wmi/rgb_zones/*; do
      echo "0f84fa" | sudo tee $F
    done
  '';

  bindfsMountOptions = [
    "force-user=lantian"
    "force-group=wheel"
    "create-for-user=root"
    "create-for-group=root"
    "chown-ignore"
    "chgrp-ignore"
    "xattr-none"
  ];
in
{
  imports = [
    ../../nixos/none.nix

    ./hardware-configuration.nix
    ./media-center.nix

    ../../nixos/client-components/network-manager.nix

    ../../nixos/optional-apps/flexget.nix
    ../../nixos/optional-apps/ksmbd.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/resilio.nix
  ];

  # ECC RAM
  hardware.rasdaemon.enable = true;

  # Handle multiple NICs
  networking.usePredictableInterfaceNames = lib.mkForce true;

  # Reduce idle power consumption
  powerManagement.powertop.enable = true;

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

  services.yggdrasil.regions = [ "united-states" "canada" ];
}
