{ config, pkgs, ... }:

{
  age.secrets.epicgames-claimer-env.file = pkgs.secrets + "/epicgames-claimer-env.age";

  virtualisation.oci-containers.containers.epicgames-claimer = {
    image = "docker.io/luminoleon/epicgames-claimer:dev";
    environmentFiles = [ config.age.secrets.epicgames-claimer-env.path ];
    volumes = [
      "/var/lib/epicgames-claimer:/User_Data"
    ];
  };
}
