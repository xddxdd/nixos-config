{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader = {
    grub =
      {
        enable = true;
        default = if LT.this.hasTag LT.tags.client then "saved" else 0;
        splashImage = null;
        font = lib.mkDefault "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF.ttf";
        fontSize = lib.mkDefault 16;
      }
      // (
        if pkgs.stdenv.isx86_64 then
          {
            efiInstallAsRemovable = lib.mkForce false;
            extraInstallCommands = lib.optionalString config.boot.loader.grub.efiSupport (
              lib.concatMapStringsSep "\n" (
                args:
                let
                  efiSysMountPoint = if args.efiSysMountPoint == null then args.path else args.efiSysMountPoint;
                  efiSysMountPoint' = lib.replaceStrings [ "/" ] [ "-" ] efiSysMountPoint;
                  bootloaderId =
                    if args.efiBootloaderId == null then "NixOS${efiSysMountPoint'}" else args.efiBootloaderId;
                in
                ''
                  mkdir -p ${args.path}/EFI/Boot
                  cp -f ${args.path}/EFI/grub/grubx64.efi ${args.path}/EFI/Boot/bootx64.efi \
                    || cp -f ${args.path}/EFI/${bootloaderId}/grubx64.efi ${args.path}/EFI/Boot/bootx64.efi \
                    || true
                ''
              ) config.boot.loader.grub.mirroredBoots
            );
          }
        else
          { efiInstallAsRemovable = true; }
      );
  };

  console.earlySetup = true;

  systemd.services.systemd-sysctl.serviceConfig = {
    ExecStart = [
      ""
      "/bin/sh -c \"${pkgs.systemd}/lib/systemd/systemd-sysctl; exit 0\""
    ];
  };
}
