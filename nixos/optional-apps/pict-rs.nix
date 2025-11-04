{
  pkgs,
  lib,
  LT,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  services.pict-rs = {
    enable = true;
    package = pkgs.pict-rs;
    port = LT.port.Pict-RS;
  };

  systemd.services.pict-rs = {
    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";
      DynamicUser = lib.mkForce false;
      User = "pict-rs";
      Group = "pict-rs";
      StateDirectory = "pict-rs";

      MemoryDenyWriteExecute = lib.mkForce false;
    };
  };

  users.users.pict-rs = {
    group = "pict-rs";
    isSystemUser = true;
  };
  users.groups.pict-rs = { };
}
