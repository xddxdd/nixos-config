{ pkgs, ... }:
{
  services.proxmox-ve.enable = true;

  systemd.services.pvedaemon.path = with pkgs; [ util-linux ];
  systemd.services.pve-guests.path = with pkgs; [ util-linux ];
}
