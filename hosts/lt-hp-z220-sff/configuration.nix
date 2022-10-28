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
    ../../nixos/client-components/xorg.nix

    ../../nixos/optional-apps/flexget.nix
    ../../nixos/optional-apps/ksmbd.nix
    ../../nixos/optional-apps/jellyfin.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/transmission-daemon.nix
  ];

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

  services.xserver.enable = lib.mkForce false;

  systemd.services.jellyfin = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
  };

  services.transmission.settings = {
    download-dir = "/mnt/storage/downloads";

    # Speed limit of private trackets
    speed-limit-down = 25600;
    speed-limit-down-enabled = false;
    speed-limit-up = 25600;
    speed-limit-up-enabled = true;
  };
  system.activationScripts.transmission-download-auto =
    let
      cfg = config.services.transmission;
    in
    ''
      install -d -m '${cfg.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '/mnt/storage/downloads-auto'
    '';
  systemd.services.transmission = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig.BindPaths = [
      "/mnt/storage/downloads-auto"
    ];
  };
}
