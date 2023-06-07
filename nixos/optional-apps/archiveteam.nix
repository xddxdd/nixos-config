{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  virtualisation.oci-containers.containers.archiveteam = {
    extraOptions = ["--pull" "always"];
    image = "atdr.meo.ws/archiveteam/reddit-grab";
    cmd = ["--concurrent" "5" "lantian"];
  };
}
