{ lib, ... }:
{
  systemd.sysusers.enable = true;
  system.etc.overlay.enable = true;
  system.etc.overlay.mutable = true;
  users.mutableUsers = lib.mkForce true;

  system.switch = {
    enable = false;
    enableNg = true;
  };
}
