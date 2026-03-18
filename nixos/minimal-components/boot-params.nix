{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  installRandomStarRailGrubTheme = pkgs.writeShellScript "install-random-star-rail-grub-theme" ''
    # Select random Star Rail Grub theme
    THEME_PATH=$(ls -1 ${inputs.honkai-railway-grub-theme}/assets/themes | grep "_cn" | sort -R | head -n1)
    echo "Randomly selected theme $THEME_PATH"
    if [ -d "/boot/theme" ]; then
      ${pkgs.rsync}/bin/rsync -ar --delete-after \
        ${inputs.honkai-railway-grub-theme}/assets/themes/$THEME_PATH/ \
        /boot/theme/
      echo "Rsync complete"
    else
      echo "/boot/theme not found, not installing theme"
    fi
  '';
in
{
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub = {
    enable = true;
    default = if LT.this.hasTag LT.tags.client then "saved" else 0;
    font = lib.mkForce "${pkgs.nerd-fonts.ubuntu-mono}/share/fonts/truetype/NerdFonts/UbuntuMono/UbuntuMonoNerdFontMono-Regular.ttf";
    fontSize = lib.mkForce 16;
    efiInstallAsRemovable = config.boot.loader.grub.efiSupport;

    extraInstallCommands = ''
      ${installRandomStarRailGrubTheme}
    '';
  };

  console.earlySetup = true;

  honkai-railway-grub-theme = {
    enable = true;
    theme = "Evernight_cn";
  };
  stylix.targets.grub.enable = lib.mkForce false;
  systemd.services.install-random-star-rail-grub-theme = {
    description = "Install Random Star Rail Grub Theme";
    after = [ "boot.mount" ];
    requires = [ "boot.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${installRandomStarRailGrubTheme}";
      Type = "oneshot";
    };
  };

  systemd.services.systemd-sysctl.serviceConfig = {
    ExecStart = [
      ""
      "/bin/sh -c \"${pkgs.systemd}/lib/systemd/systemd-sysctl; exit 0\""
    ];
  };
}
