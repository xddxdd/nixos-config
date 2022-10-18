{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  age.secrets.waline-env.file = pkgs.secrets + "/waline-env.age";

  virtualisation.oci-containers.containers = {
    waline = {
      extraOptions = [ "--pull" "always" ];
      image = "lizheming/waline";
      ports = [ "${LT.this.ltnet.IPv4}:${LT.portStr.Waline}:8360" ];
      environmentFiles = [ config.age.secrets.waline-env.path ];
    };
  };
}
