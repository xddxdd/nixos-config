{ pkgs, lib, LT, config, utils, inputs, ... }@args:

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

  services.lvm.dmeventd.enable = true;
}
