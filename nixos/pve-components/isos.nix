{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [
    "L+ /var/lib/vz/template/iso/virtio-win.iso - - - - ${pkgs.virtio-win.src}"
  ];
}
