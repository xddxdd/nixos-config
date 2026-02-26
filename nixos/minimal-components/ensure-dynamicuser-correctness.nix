{ config, lib, ... }:
{
  # Make sure custom users are not dynamic
  assertions = lib.mapAttrsToList (
    n: v:
    let
      du = v.serviceConfig.DynamicUser or false;
      user = v.serviceConfig.User or "";
    in
    {
      assertion = (user != "root" && user != "lantian") || (!du && du != "yes");
      message = "${n} has DynamicUser enabled for ${user}";
    }
  ) config.systemd.services;
}
