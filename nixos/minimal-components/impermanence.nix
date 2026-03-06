{
  lib,
  config,
  LT,
  ...
}:
let
  isBtrfsRoot = (config.fileSystems."/nix".fsType or "") == "btrfs";
in
{
  preservation.enable = true;
  preservation.preserveAt."/nix/persistent" = {
    directories = LT.preservation.mkFolders (
      [
        "/var/lib"
        "/var/log"
        "/var/www"
      ]
      ++ lib.optionals (!(config.fileSystems ? "/var/cache")) [
        "/var/cache"
      ]
    );
    files = LT.preservation.mkFiles [
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
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
        "size=80%"
      ];
    };
  };

  services.btrfs.autoScrub = lib.mkIf isBtrfsRoot {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/nix" ];
  };
}
