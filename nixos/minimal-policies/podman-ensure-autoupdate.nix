{
  config,
  lib,
  ...
}:
{
  config = {
    # Make sure auto update is enabled for all containers
    assertions = lib.mapAttrsToList (n: v: {
      assertion = (v.labels."io.containers.autoupdate" or "") != "";
      message = "Container ${n} does not have auto update enabled";
    }) config.virtualisation.oci-containers.containers;
  };
}
