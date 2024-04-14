{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  backupScript = pkgs.writeShellScriptBin "backup" ''
    set -x
    DATE=$(date "+%Y%m%d")
    sudo btrfs subvol snapshot -r /mnt/root/home /mnt/root/home-$DATE
    sudo btrfs subvol snapshot -r /mnt/root/persistent /mnt/root/persistent-$DATE
    sudo btrfs send /mnt/root/home-$DATE | pv | ssh lt-home-vm.lantian.pub "btrfs receive /mnt/storage/backups"
    sudo btrfs send /mnt/root/persistent-$DATE | pv | ssh lt-home-vm.lantian.pub "btrfs receive /mnt/storage/backups"
  '';
in
{
  environment.systemPackages = [ backupScript ];
}
