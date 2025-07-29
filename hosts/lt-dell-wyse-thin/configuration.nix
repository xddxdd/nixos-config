{
  lib,
  inputs,
  config,
  ...
}:
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

  services.tlp.settings = lib.mapAttrs (n: lib.mkForce) {
    TLP_DEFAULT_MODE = "AC";
    TLP_PERSISTENT_DEFAULT = 1;
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
  };

  # Auto mount samba share
  age.secrets.samba-credentials.file = inputs.secrets + "/samba-credentials.age";
  fileSystems."/mnt/share" = {
    device = "//192.168.1.10/storage";
    fsType = "cifs";
    options = [
      "_netdev"
      "credentials=${config.age.secrets.samba-credentials.path}"
      "gid=${builtins.toString config.users.groups.lantian.gid}"
      "noauto"
      "uid=${builtins.toString config.users.users.lantian.uid}"
      "users"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
    ];
  };
}
