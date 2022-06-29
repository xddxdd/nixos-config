{ pkgs, lib, config, ... }:

{
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader = {
    grub = {
      enable = true;
      default = "saved";
      version = 2;
      splashImage = null;
      font = lib.mkDefault
        "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF.ttf";
      fontSize = lib.mkDefault 16;

    } // (if pkgs.stdenv.isx86_64 then {
      efiInstallAsRemovable = lib.mkForce false;
      extraPrepareConfig =
        let
          preloader = pkgs.fetchurl {
            url = "https://blog.hansenpartnership.com/wp-uploads/2013/PreLoader.efi";
            sha256 = "1ap5x74y2vapkbwd7bplvyz34g3f41bx0a982083ryd3qla6342h";
          };
          hashTool = pkgs.fetchurl {
            url = "https://blog.hansenpartnership.com/wp-uploads/2013/HashTool.efi";
            sha256 = "0s24q76cg0gn4m1ik5lls3m7lqkvxlf6p64h3ml21jx5xrhkb7wi";
          };
        in
        ''
          mkdir -p "@bootPath@/EFI/Boot"
          cp -f ${preloader} "@bootPath@/EFI/Boot/bootx64.efi"
          cp -f ${hashTool} "@bootPath@/EFI/Boot/HashTool.efi"
        '';
      extraInstallCommands = lib.optionalString config.boot.loader.grub.efiSupport
        (lib.concatStringsSep "\n" (builtins.map
          (args:
            let
              efiSysMountPoint = if args.efiSysMountPoint == null then args.path else args.efiSysMountPoint;
              efiSysMountPoint' = lib.replaceChars [ "/" ] [ "-" ] efiSysMountPoint;
              bootloaderId = if args.efiBootloaderId == null then "NixOS${efiSysMountPoint'}" else args.efiBootloaderId;
            in
            ''
              cp -f ${args.path}/EFI/grub/grubx64.efi ${args.path}/EFI/Boot/loader.efi \
                || cp -f ${args.path}/EFI/${bootloaderId}/grubx64.efi ${args.path}/EFI/Boot/loader.efi
            '')
          config.boot.loader.grub.mirroredBoots));

    } else {
      efiInstallAsRemovable = true;
    });
  };

  console.earlySetup = true;

  systemd.services.systemd-sysctl.serviceConfig = {
    ExecStart = [
      ""
      "/bin/sh -c \"${pkgs.systemd}/lib/systemd/systemd-sysctl; exit 0\""
    ];
  };
}
