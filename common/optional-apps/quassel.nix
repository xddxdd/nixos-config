{ pkgs, config, ... }:

{
  services.quassel = {
    enable = true;
    dataDir = "/var/lib/quassel";
    interfaces = [ "0.0.0.0" ];
  };
}
