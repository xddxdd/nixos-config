# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../nixos/hardware/qemu.nix
  ];

  boot.kernelModules = [ "nvme" ];

  boot.loader.grub.mirroredBoots = [
    { devices = [ "/dev/vda" ]; path = "/nix/boot"; }
  ];

  fileSystems."/nix" = {
    device = "/dev/vda1";
    fsType = "btrfs";
    options = [ "compress-force=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/nix/boot";
    options = [ "bind" ];
  };
}
