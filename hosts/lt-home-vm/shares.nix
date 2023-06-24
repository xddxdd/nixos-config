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
    ../../nixos/optional-apps/samba.nix
  ];

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

  lantian.resilio.storage = "/mnt/storage/media";

  fileSystems."/run/sftp" = lib.mkForce {
    device = "/mnt/storage";
    fsType = "fuse.bindfs";
    options = [
      "force-user=sftp"
      "force-group=sftp"
      "create-for-user=lantian"
      "create-for-group=users"
      "chown-ignore"
      "chgrp-ignore"
      "xattr-none"
      "x-gvfs-hide"
    ];
  };

  users.users.sftp.home = lib.mkForce "/run/sftp";
}