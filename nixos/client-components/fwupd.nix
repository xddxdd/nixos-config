{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ gnome-firmware ];

  services.fwupd.enable = true;

  systemd.services.fwupd.unitConfig.Before = [ "" ];
}
