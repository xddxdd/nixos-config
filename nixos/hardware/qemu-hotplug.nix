{ lib, ... }:
{
  boot.kernelParams = [ "memhp_default_state=online" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="cpu", ACTION=="add", TEST=="online", ATTR{online}=="0", ATTR{online}="1"
    SUBSYSTEM=="memory", ACTION=="add", TEST=="state", ATTR{state}=="offline", ATTR{state}="online"
  '';

  # ZRAM doesn't interact well with memory hotplug
  zramSwap.enable = lib.mkForce false;
}
