{ pkgs, lib, ... }:
{
  systemd.coredump.enable = false;

  boot.kernel.sysctl = {
    # Disable coredump
    "fs.suid_dumpable" = 0;
    "kernel.core_pattern" = lib.mkForce "|${lib.getExe' pkgs.coreutils "false"}";
  };
}
