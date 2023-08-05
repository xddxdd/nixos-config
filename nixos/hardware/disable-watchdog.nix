{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  boot.extraModprobeConfig = ''
    blacklist iTCO_wdt
    blacklist iTCO_vendor_support
    blacklist sp5100_tco
  '';
  boot.kernelParams = ["nowatchdog" "nmi_watchdog=0"];
}
