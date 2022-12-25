{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/optional-apps/ksmbd.nix
  ];

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
    ];
  };

  users.users.sftp.home = lib.mkForce "/run/sftp";
}
