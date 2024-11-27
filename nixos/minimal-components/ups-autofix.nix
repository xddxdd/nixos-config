{ config, lib, ... }:
{
  systemd.services.upsd = lib.mkIf config.power.ups.enable {
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  };
  systemd.services.upsmon = lib.mkIf config.power.ups.upsmon.enable {
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  };
}
