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
    ../../nixos/optional-apps/nfs.nix
    ../../nixos/optional-apps/samba.nix
  ];

  services.nfs.server.exports = ''
    /run/nfs/storage 198.18.0.0/24(rw,insecure,no_subtree_check,mountpoint,all_squash,anonuid=${builtins.toString config.users.users.lantian.uid},anongid=${builtins.toString config.users.groups.lantian.gid})
  '';

  services.samba.shares = {
    "storage" = {
      "path" = "/mnt/storage";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "root";
      "force group" = "users";
      "valid users" = "lantian";
    };
  };

  lantian.syncthing.storage = "/mnt/storage/media";

  fileSystems = {
    "/run/sftp" = lib.mkForce {
      device = "/mnt/storage";
      fsType = "fuse.bindfs";
      options = [
        "force-user=sftp"
        "force-group=sftp"
        "perms=700"
        "create-for-user=lantian"
        "create-for-group=users"
        "chmod-ignore"
        "chown-ignore"
        "chgrp-ignore"
        "xattr-none"
        "x-gvfs-hide"
      ];
    };
    "/run/nfs/storage" = {
      device = "/mnt/storage";
      options = ["bind" "x-gvfs-hide"];
    };
  };

  users.users.sftp.home = lib.mkForce "/run/sftp";
}
