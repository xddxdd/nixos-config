{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    address = "${thisHost.ltnet.IPv4Prefix}.1:8200";
    storageBackend = "file";
    storagePath = "/var/lib/vault";
    extraConfig = ''
      ui = 1
    '';
  };
}
