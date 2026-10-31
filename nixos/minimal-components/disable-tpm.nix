{
  config,
  lib,
  ...
}:
lib.mkIf (config.lantian.hostType == "vm") {
  boot.initrd.systemd.tpm2.enable = false;
  boot.kernelParams = [ "initcall_blacklist=tpm_init,init_tis" ];
  security.tpm2.enable = false;
  systemd.tpm2.enable = false;
}
