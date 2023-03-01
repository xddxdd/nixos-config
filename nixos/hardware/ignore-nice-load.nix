{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  boot.kernelParams = [
    "cpufreq.default_governor=ondemand"
    "intel_pstate=passive"
  ];

  powerManagement.cpuFreqGovernor = "ondemand";

  systemd.services.cpufreq.postStart = ''
    echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/ignore_nice_load
    echo 95 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
  '';
}
