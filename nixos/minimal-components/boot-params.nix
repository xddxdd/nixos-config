{
  pkgs,
  lib,
  LT,
  ...
}:
{
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub = {
    enable = true;
    default = if LT.this.hasTag LT.tags.client then "saved" else 0;
    font = lib.mkForce "${pkgs.nerd-fonts.ubuntu-mono}/share/fonts/truetype/NerdFonts/UbuntuMono/UbuntuMonoNerdFontMono-Regular.ttf";
    fontSize = lib.mkForce 16;
    efiInstallAsRemovable = true;
  };

  console.earlySetup = true;

  honkai-railway-grub-theme = {
    enable = true;
    theme = "Evernight_cn";
  };
  stylix.targets.grub.enable = lib.mkForce false;

  systemd.services.systemd-sysctl.serviceConfig = {
    ExecStart = [
      ""
      "/bin/sh -c \"${pkgs.systemd}/lib/systemd/systemd-sysctl; exit 0\""
    ];
  };
}
