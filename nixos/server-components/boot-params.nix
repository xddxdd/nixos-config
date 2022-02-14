{ pkgs, config, ... }:

{
  boot.kernelParams = [
    "nofb"
    "nomodeset"
    "vga=normal"
  ];

  boot.loader.grub = {
    memtest86.enable = true;

    extraFiles = {
      "netboot.xyz.efi" = pkgs.lib.mkIf (pkgs.stdenv.isx86_64 && config.boot.loader.grub.efiSupport) "${pkgs.netboot-xyz}/netboot.xyz.efi";
      "netboot.xyz.lkrn" = pkgs.lib.mkIf (pkgs.stdenv.isx86_64 && !config.boot.loader.grub.efiSupport) "${pkgs.netboot-xyz}/netboot.xyz.lkrn";
    };
    extraEntries = pkgs.lib.optionalString (pkgs.stdenv.isx86_64 && config.boot.loader.grub.efiSupport) ''
      menuentry "Netboot.xyz" {
        chainloader @bootRoot@/netboot.xyz.efi;
      }
    '' + pkgs.lib.optionalString (pkgs.stdenv.isx86_64 && !config.boot.loader.grub.efiSupport) ''
      menuentry "Netboot.xyz" {
        linux16 @bootRoot@/netboot.xyz.lkrn;
      }
    '';
  };
}
