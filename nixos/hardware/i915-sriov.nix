{
  pkgs,
  config,
  ...
}:
{
  boot.extraModprobeConfig = ''
    options i915 max_vfs=7
  '';
  boot.extraModulePackages = [ config.boot.kernelPackages.i915-sriov ];

  systemd.services.i915-sriov = {
    description = "Enable i915 SRIOV";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    requires = [ "systemd-modules-load.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      I915_PATH=/sys/devices/pci0000:00/0000:00:02.0
      NUMVFS=$(cat "$I915_PATH/sriov_totalvfs")
      echo 0 > "$I915_PATH/sriov_drivers_autoprobe"
      echo "$NUMVFS" > "$I915_PATH/sriov_numvfs"

      ${pkgs.kmod}/bin/modprobe -v vfio-pci

      for VF in $I915_PATH/virtfn*; do
        PCI_ADDR=$(readlink -f $VF)
        PCI_ADDR=''${PCI_ADDR##*/}
        echo vfio-pci > "$VF/driver_override"
        echo "$PCI_ADDR" > /sys/bus/pci/drivers_probe
      done
    '';
  };

}
