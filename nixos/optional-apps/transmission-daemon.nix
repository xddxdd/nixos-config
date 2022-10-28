{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  services.transmission = {
    enable = true;
    user = "lantian";
    group = "wheel";
    downloadDirPermissions = "775";
    settings = {
      cache-size-mb = 64;
      download-dir = lib.mkDefault "/nix/persistent/media/Transmission";
      download-queue-enabled = false;
      encryption = 2;
      idle-seeding-limit-enabled = false;
      incomplete-dir-enabled = false;
      peer-limit-global = 10000;
      peer-limit-per-torrent = 10000;
      peer-port = 57912;
      peer-socket-tos = "lowcost";
      queue-stalled-enabled = false;
      rename-partial-files = true;
      rpc-bind-address = LT.this.ltnet.IPv4;
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;
      seed-queue-enabled = false;
    };
  };
}
