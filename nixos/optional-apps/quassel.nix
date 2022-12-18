{ pkgs, lib, LT, config, utils, inputs, ... }@args:

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
