{
  pkgs,
  ...
}:
{
  systemd.services.smfc = {
    description = "Super Micro Fan Control";
    wantedBy = [ "multi-user.target" ];
    # DefaultDependencies adds Conflicts=/Before=shutdown.target, which stops fan
    # control the moment shutdown starts. Keep regulating until poweroff.
    unitConfig.DefaultDependencies = false;
    after = [ "sysinit.target" ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.smfc}/bin/smfc --config ${./smfc.toml}";
      ExecStopPost = "${pkgs.smfc}/bin/smfc --failsafe";
      Restart = "always";
      RestartSec = "3";
      WatchdogSec = "60";
      TimeoutStartSec = "120";
      TimeoutStopSec = "60";

      PrivateDevices = false;
      DevicePolicy = "closed";
      DeviceAllow = [ "/dev/ipmi0 r" ];
    };
  };
  lantian.harden.smfc = {
    enable = true;
    enableTripwire = true;
    realtime = true;
  };
}
