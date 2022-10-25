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
    "create-for-user=rslsync"
    "create-for-group=rslsync"
    "chown-ignore"
    "chgrp-ignore"
    "xattr-none"
  ];
in
{
  imports = [
    ../../nixos/none.nix

    ./hardware-configuration.nix

    ../../nixos/client-components/network-manager.nix

    ../../nixos/optional-apps/ksmbd.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/resilio.nix
  ];

  # services.beesd.filesystems.root = {
  #   spec = "/nix";
  #   hashTableSizeMB = 128;
  #   verbosity = "crit";
  # };

  services.ksmbd = {
    enable = true;
    shares = {
      "lantian" = {
        "path" = "/home/lantian";
        "read only" = false;
        "force user" = "lantian";
        "force group" = "users";
        "valid users" = "lantian";
      };
    };
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];
}
