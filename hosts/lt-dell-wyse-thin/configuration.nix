{ lib, LT, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix

    ../../nixos/client-components/fwupd.nix
    ../../nixos/client-components/hidpi.nix
    ../../nixos/client-components/network-manager.nix
    ../../nixos/client-components/networking.nix
    ../../nixos/client-components/pipewire
    ../../nixos/client-components/tlp.nix
  ];

  lantian.hidpi = 1.5;

  services.fwupd.enable = true;

  services.tlp.settings = lib.mapAttrs (_n: lib.mkForce) {
    TLP_DEFAULT_MODE = "AC";
    TLP_PERSISTENT_DEFAULT = 1;
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
  };

  # Auto mount NFS share
  fileSystems."/mnt/share" = {
    device = "${LT.hosts."lt-home-vm".ltnet.IPv4}:/storage";
    fsType = "nfs";
    options = [
      "_netdev"
      "noatime"
      "noauto"
      "clientaddr=${LT.this.ltnet.IPv4}"
      "hard"
      "vers=4.2"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
    ];
  };
}
