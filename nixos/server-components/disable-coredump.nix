{ pkgs, lib, config, utils, inputs, ... }@args:

{
  systemd.coredump.enable = false;

  boot.kernel.sysctl = lib.mkIf (!config.boot.isContainer) {
    # Disable coredump
    "fs.suid_dumpable" = 0;
    "kernel.core_pattern" = lib.mkForce "|${pkgs.coreutils}/bin/false";
  };
}
