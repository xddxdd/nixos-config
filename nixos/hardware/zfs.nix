{ LT, pkgs, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.package = pkgs.zfs_2_3;
  boot.zfs.forceImportAll = true;
  preservation.preserveAt."/nix/persistent" = {
    directories = LT.preservation.mkFolders [
      {
        directory = "/etc/zfs";
        inInitrd = true;
      }
    ];
  };
}
