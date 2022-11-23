{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
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
