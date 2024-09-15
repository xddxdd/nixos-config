{ pkgs, ... }:
let
  extraPath = with pkgs; [
    util-linux
    swtpm
  ];
in
{
  services.proxmox-ve.enable = true;

  systemd.services.pvedaemon.path = extraPath;
  systemd.services.pve-guests.path = extraPath;
}
