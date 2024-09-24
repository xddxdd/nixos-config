{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot.kernelParams = [
    "nofb"
    "nomodeset"
    "vga=normal"
  ];

  boot.loader.grub = {
    memtest86.enable = pkgs.stdenv.isx86_64;

    extraFiles = {
      "netboot.xyz.efi" = lib.mkIf (
        pkgs.stdenv.isx86_64 && config.boot.loader.grub.efiSupport
      ) "${pkgs.nur-xddxdd.netboot-xyz}/netboot.xyz.efi";
      "netboot.xyz.lkrn" = lib.mkIf (
        pkgs.stdenv.isx86_64 && !config.boot.loader.grub.efiSupport
      ) "${pkgs.nur-xddxdd.netboot-xyz}/netboot.xyz.lkrn";
    };
    extraEntries =
      lib.optionalString (pkgs.stdenv.isx86_64 && config.boot.loader.grub.efiSupport) ''
        menuentry "Netboot.xyz" {
          chainloader @bootRoot@/netboot.xyz.efi;
        }
      ''
      + lib.optionalString (pkgs.stdenv.isx86_64 && !config.boot.loader.grub.efiSupport) ''
        menuentry "Netboot.xyz" {
          linux16 @bootRoot@/netboot.xyz.lkrn;
        }
      '';
  };
}
