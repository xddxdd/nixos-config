{ config, pkgs, lib, ... }:

{
  boot.loader.systemd-boot = {
    extraFiles = {
      "EFI/Boot/bootx64.efi" = pkgs.fetchurl {
        url = "https://blog.hansenpartnership.com/wp-uploads/2013/PreLoader.efi";
        sha256 = "1ap5x74y2vapkbwd7bplvyz34g3f41bx0a982083ryd3qla6342h";
      };
      "EFI/Boot/HashTool.efi" = pkgs.fetchurl {
        url = "https://blog.hansenpartnership.com/wp-uploads/2013/HashTool.efi";
        sha256 = "0s24q76cg0gn4m1ik5lls3m7lqkvxlf6p64h3ml21jx5xrhkb7wi";
      };
      "EFI/Boot/loader.efi" = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-bootx64.efi";
    };
  };
}
