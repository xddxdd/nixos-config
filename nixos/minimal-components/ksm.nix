{
  config,
  lib,
  ...
}:
{
  hardware.ksm.enable = lib.mkDefault (config.lantian.hostType != "vm");

  boot.kernelParams = lib.optionals (!config.hardware.ksm.enable) [
    "initcall_blacklist=ksm_init"
    "transparent_hugepage=never"
  ];
}
