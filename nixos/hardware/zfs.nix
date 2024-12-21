{ LT, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportAll = true;
  preservation.preserveAt."/nix/persistent" = {
    directories = builtins.map LT.preservation.mkFolder [
      {
        directory = "/etc/zfs";
        inInitrd = true;
      }
    ];
  };
}
