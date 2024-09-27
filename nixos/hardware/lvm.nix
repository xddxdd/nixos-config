{ lib, ... }:
{
  boot.initrd.kernelModules = [
    "dm-cache"
    "dm-integrity"
    "dm-raid"
    "dm-writecache"
    "raid0"
    "raid1"
    "raid10"
    "raid456"
  ];

  boot.swraid.enable = lib.mkForce true;

  services.lvm.dmeventd.enable = true;

  environment.etc."lvm/lvm.conf".text = ''
    devices/filter = [ "r|/dev/zd*|" ]
  '';
}
