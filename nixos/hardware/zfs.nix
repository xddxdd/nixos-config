{ pkgs, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.package = pkgs.zfs_2_3;
  boot.zfs.forceImportAll = true;
  lantian.preservation.directories = [
    {
      directory = "/etc/zfs";
      inInitrd = true;
    }
  ];
}
