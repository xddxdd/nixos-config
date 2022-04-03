{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  age.secrets.v2ray-conf = {
    name = "v2ray.json";
    file = pkgs.secrets + "/v2ray-conf.age";
    owner = "v2ray";
    group = "v2ray";
  };

  services.v2ray = {
    enable = true;
    package = pkgs.xray;
    configFile = config.age.secrets.v2ray-conf.path;
  };

  systemd.services.v2ray.serviceConfig = LT.serviceHarden // {
    User = "v2ray";
    Group = "v2ray";
  };

  users.users.v2ray = {
    group = "v2ray";
    isSystemUser = true;
  };
  users.groups.v2ray = { };
}
