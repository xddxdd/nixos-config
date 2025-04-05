{ pkgs, ... }:
{
  boot.extraModprobeConfig = ''
    blacklist virtio_balloon
    install virtio_balloon ${pkgs.coreutils}/bin/true
  '';
}
