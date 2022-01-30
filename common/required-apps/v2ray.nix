{ config, pkgs, ... }:

let
  LT = import ../helpers.nix { inherit config pkgs; };
in
{
  age.secrets.v2ray-conf = {
    name = "v2ray.json";
    file = ../../secrets/v2ray-conf.age;
    owner = "v2ray";
    group = "v2ray";
  };

  services.v2ray = {
    enable = true;
    package = pkgs.nur.repos.xddxdd.xray;
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
