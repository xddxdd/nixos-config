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
    ../../nixos/server.nix

    ./hardware-configuration.nix
    ./media-center.nix
    ./shares.nix

    ../../nixos/client-components/cups.nix

    ../../nixos/optional-apps/calibre-cops.nix
    ../../nixos/optional-apps/clamav.nix
    ../../nixos/optional-apps/fastapi-dls.nix
    ../../nixos/optional-apps/genshin-cockpy.nix
    ../../nixos/optional-apps/genshin-grasscutter.nix
    ../../nixos/optional-apps/genshin-soggy.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/nvidia/grid-extension.nix
    ../../nixos/optional-apps/pterodactyl-panel.nix
    ../../nixos/optional-apps/pterodactyl-wings.nix
    ../../nixos/optional-apps/sftp-server.nix
    ../../nixos/optional-apps/syncthing.nix
    ../../nixos/optional-apps/tachidesk.nix
    ../../nixos/optional-apps/vlmcsd.nix

    ../../nixos/optional-cron-jobs/oci-arm-host-capacity.nix

    "${inputs.secrets}/nixos-hidden-module/7319533cbc15d7ce"
    "${inputs.secrets}/nixos-hidden-module/8eca84a1c0f3007b"
  ];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 16;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  services.beesd.filesystems.storage = {
    spec = config.fileSystems."/mnt/storage".device;
    hashTableSizeMB = 128;
    verbosity = "crit";
    extraOptions = ["--loadavg-target" "4"];
  };

  services.calibre-cops.libraryPath = "/mnt/storage/media/Calibre Library";

  # Rename to LAN to apply correct firewall rules
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{device/vendor}=="0x1af4", ATTR{device/device}=="0x0001",NAME="lan0"
  '';

  systemd.network.networks.lan0 = {
    address = ["192.168.1.10/24" "fc00:192:168:1::10/64"];
    gateway = ["192.168.1.1" "fc00:192:168:1::1"];
    matchConfig.Name = "lan0";
  };

  services.avahi.enable = lib.mkForce true;
  services.printing = {
    browsing = true;
    defaultShared = true;
    listenAddresses = ["127.0.0.1:631" "192.168.1.10:631"];
    allowFrom = ["all"];
  };

  lantian.syncthing.storage = "/mnt/storage/media";

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
