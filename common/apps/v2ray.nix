{ config, pkgs, ... }:

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
