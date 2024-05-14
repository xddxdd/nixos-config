{ pkgs, lib, ... }:
{
  systemd.coredump.enable = false;

  boot.kernel.sysctl = {
    # Disable coredump
    "fs.suid_dumpable" = 0;
    "kernel.core_pattern" = lib.mkForce "|${pkgs.coreutils}/bin/false";
  };
}
