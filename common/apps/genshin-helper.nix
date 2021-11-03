{ config, pkgs, ... }:

{
  age.secrets.genshin-impact-cookies.file = ../../secrets/genshin-impact-cookies.age;

  virtualisation.oci-containers.containers.genshin-helper = {
    image = "yindan/genshinhelper:2.0.2";
    environmentFiles = [ config.age.secrets.genshin-impact-cookies.path ];
  };
}
