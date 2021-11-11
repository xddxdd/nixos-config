{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  age.secrets.v2ray-conf = {
    name = "v2ray.json";
    file = ../../secrets/v2ray-conf.age;
  };

  services.v2ray = {
    enable = true;
    package = pkgs.nur.repos.xddxdd.xray;
    configFile = config.age.secrets.v2ray-conf.path;
  };
}
