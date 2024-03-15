{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  environment.systemPackages = with pkgs; [ sgx-software-enable ];
  services.aesmd.enable = true;
  hardware.cpu.intel.sgx = {
    provision.enable = true;
    enableDcapCompat = true;
  };
}
