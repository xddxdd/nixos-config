{
  lib,
  LT,
  config,
  ...
}:
{
  imports = [
    ../../nixos/optional-apps/nfs.nix
    ../../nixos/optional-apps/samba.nix
  ];

  services.nfs.server.exports = ''
    /run/nfs/storage 198.18.0.0/24(rw,insecure,no_subtree_check,mountpoint,all_squash,fsid=1,anonuid=${builtins.toString config.users.users.lantian.uid},anongid=${builtins.toString config.users.groups.lantian.gid})
  '';

  services.samba.settings = {
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
      "veto files" = "/._*/.DS_Store/Thumbs.db/";
      "delete veto files" = "yes";
    };
  };

  lantian.syncthing.storage = "/mnt/storage/media";

  fileSystems = {
    "/run/sftp" = lib.mkForce {
      device = "/mnt/storage";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions' [
        "force-user=sftp"
        "force-group=sftp"
        "perms=700"
        "create-for-user=lantian"
        "create-for-group=users"
        "create-with-perms=755"
        "chmod-ignore"
      ];
    };
    "/run/nfs/storage" = {
      device = "/mnt/storage";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions' [
        "force-user=lantian"
        "force-group=lantian"
        "perms=700"
        "create-for-user=lantian"
        "create-for-group=users"
        "create-with-perms=755"
        "chmod-ignore"
      ];
    };
  };

  users.users.sftp.home = lib.mkForce "/run/sftp";
}
