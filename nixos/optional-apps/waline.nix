{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  age.secrets.waline-env.file = inputs.secrets + "/waline-env.age";

  virtualisation.oci-containers.containers = {
    waline = {
      extraOptions = [ "--pull" "always" ];
      image = "lizheming/waline";
      ports = [ "${LT.this.ltnet.IPv4}:${LT.portStr.Waline}:8360" ];
      environmentFiles = [ config.age.secrets.waline-env.path ];
    };
  };
}
