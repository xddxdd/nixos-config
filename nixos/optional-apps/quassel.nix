{ pkgs, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  services.quassel = {
    enable = true;
    dataDir = "/var/lib/quassel";
    interfaces = [ "0.0.0.0" ];
  };

  systemd.services.quassel.serviceConfig = LT.serviceHarden // {
    StateDirectory = "quassel";
    MemoryDenyWriteExecute = false;
  };
}
