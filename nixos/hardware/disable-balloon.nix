{ pkgs,
  lib, ... }:
{
  boot.extraModprobeConfig = ''
    blacklist virtio_balloon
    install virtio_balloon ${lib.getExe' pkgs.coreutils "true"}
  '';
}
