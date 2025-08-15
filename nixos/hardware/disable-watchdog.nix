{ lib, ... }:
{
  boot.extraModprobeConfig = ''
    blacklist iTCO_wdt
    blacklist iTCO_vendor_support
    blacklist sp5100_tco
  '';
  boot.kernelParams = [
    "nowatchdog"
    "nmi_watchdog=0"
  ];

  systemd.settings.Manager = {
    RebootWatchdogSec = lib.mkForce null;
    RuntimeWatchdogSec = lib.mkForce null;
    KExecWatchdogSec = lib.mkForce null;
  };
}
