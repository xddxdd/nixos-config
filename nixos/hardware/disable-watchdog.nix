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

  systemd.watchdog = {
    kexecTime = lib.mkForce null;
    rebootTime = lib.mkForce null;
    runtimeTime = lib.mkForce null;
  };
}
