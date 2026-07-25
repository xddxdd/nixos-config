{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub = {
    enable = true;
    useInstallNg = true;
    default = if LT.this.hasTag LT.tags.client then "saved" else 0;
    font = lib.mkForce "${pkgs.nerd-fonts.ubuntu-mono}/share/fonts/truetype/NerdFonts/UbuntuMono/UbuntuMonoNerdFontMono-Regular.ttf";
    fontSize = lib.mkForce 16;
    efiInstallAsRemovable = config.boot.loader.grub.efiSupport;
  };

  console.earlySetup = true;

  systemd.services.systemd-sysctl.serviceConfig = {
    ExecStart = [
      ""
      "/bin/sh -c \"${pkgs.systemd}/lib/systemd/systemd-sysctl; exit 0\""
    ];
  };
}
