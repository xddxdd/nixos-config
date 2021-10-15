{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  virtualisation.oci-containers.containers = {
    asf = {
      image = "justarchi/archisteamfarm:released";
      ports = [
        "${thisHost.ltnet.IPv4Prefix}.1:13242:1242"
      ];
      volumes = [
        "/var/lib/asf:/app/config"
      ];
    };
  };
}
