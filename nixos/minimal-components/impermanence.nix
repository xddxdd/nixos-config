{ lib, config, ... }:
let
  isBtrfsRoot = (config.fileSystems."/nix".fsType or "") == "btrfs";
in
{
  environment.persistence."/nix/persistent" = {
    hideMounts = true;
    directories = [
      "/var/cache"
      "/var/lib"
      "/var/log"
      "/var/www"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  age.identityPaths = [ "/nix/persistent/etc/ssh/ssh_host_ed25519_key" ];

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "relatime"
        "mode=755"
        "nosuid"
        "nodev"
      ];
    };
  };

  services.btrfs.autoScrub = lib.mkIf isBtrfsRoot {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/nix" ];
  };
}
