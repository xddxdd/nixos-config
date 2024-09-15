{ pkgs, config, ... }:
let
  extraPath =
    with pkgs;
    (
      [
        util-linux
        swtpm
      ]
      ++ (lib.optionals (config.boot.supportedFilesystems.zfs or false) [
        zfs
      ])
    );
in
{
  services.proxmox-ve.enable = true;

  systemd.services.pvedaemon.path = extraPath;
  systemd.services.pve-guests.path = extraPath;
}
