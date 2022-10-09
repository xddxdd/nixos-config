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
      download-dir = lib.mkDefault "/nix/persistent/media/Transmission";
      incomplete-dir-enabled = false;
      peer-port = 57912;
      rpc-bind-address = LT.this.ltnet.IPv4;
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;
    };
  };
}
