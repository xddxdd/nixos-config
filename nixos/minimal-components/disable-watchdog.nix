{
  lib,
  config,
  ...
}:
let
  cfg = config.lantian.disable-watchdog;
in
{
  options.lantian.disable-watchdog = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable hardware watchdog and systemd watchdog integration.";
    };
  };

  config = lib.mkIf cfg.enable {
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
  };
}
