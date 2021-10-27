{ config, pkgs, ... }:

{
  virtualisation.oci-containers.containers.epicgames-claimer = {
    image = "ghcr.io/jackblk/epicgames-freebies-claimer:latest";
    volumes = [
      "/var/lib/epicgames-claimer:/app/data"
    ];
  };
}
