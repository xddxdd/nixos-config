{ pkgs, ... }:
{
  boot.kernelModules = [
    "ipmi_devintf"
    "ipmi_si"
  ];

  systemd.services.asrock-fan-control = {
    description = "ASRock EPYCD8 fan control";
    wantedBy = [ "multi-user.target" ];
    # DefaultDependencies adds Conflicts=/Before=shutdown.target, which stops fan
    # control the moment shutdown starts. Keep regulating until poweroff.
    unitConfig.DefaultDependencies = false;
    after = [
      "sysinit.target"
      "systemd-modules-load.service"
      "nvidia-persistenced.service"
    ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.asrock-fan-control}/bin/asrock-fan-control --config ${./fans.toml}";
      ExecStopPost = "${pkgs.asrock-fan-control}/bin/asrock-fan-control --failsafe --config ${./fans.toml}";
      Restart = "always";
      RestartSec = "3";
      WatchdogSec = "60";
      TimeoutStartSec = "120";
      TimeoutStopSec = "60";

      PrivateDevices = false;
      ProcSubset = "all";
      MemoryDenyWriteExecute = false;
      DevicePolicy = "closed";
      DeviceAllow = [
        "/dev/ipmi0 r"
        "/dev/nvidia0 rw"
        "/dev/nvidia1 rw"
        "/dev/nvidia2 rw"
        "/dev/nvidiactl rw"
      ];
    };
  };
  lantian.harden.asrock-fan-control = {
    enable = true;
    enableTripwire = true;
    realtime = true;
    cuda = true;
  };
}
