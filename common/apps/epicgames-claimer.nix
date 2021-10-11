{ config, pkgs, ... }:

{
  virtualisation.oci-containers.containers.epicgames-claimer = {
    image = "ghcr.io/jackblk/epicgames-freebies-claimer:latest";
    volumes = [
      "/var/lib/epicgames-claimer/config.json:/app/config.json"
      "/var/lib/epicgames-claimer/config.json:/app/data/config.json"
      "/var/lib/epicgames-claimer/device_auths.json:/app/device_auths.json"
      "/var/lib/epicgames-claimer/device_auths.json:/app/data/device_auths.json"
    ];
  };
}
