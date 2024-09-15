{ ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportAll = true;
  environment.persistence."/nix/persistent" = {
    directories = [ "/etc/zfs" ];
  };
}
