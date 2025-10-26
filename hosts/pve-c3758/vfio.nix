{ pkgs, lib, ... }:
{
  boot.kernelModules = [
    "vfio-pci"
    "qat_c3xxx"
    "qat_c3xxxvf"
  ];
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "amd_iommu=on"
    "isolcpus=4-7"
    "nohz_full=4-7"
    "rcu_nocbs=4-7"
  ];
  boot.extraModprobeConfig =
    let
      vfioIds = [
        "8086:125c" # Intel I226-V
        "8086:15c4" # Intel X553
      ];
      blacklistedModules = [
        "igc" # Intel I226-V
        "ixgbe" # Intel X553
      ];
    in
    ''
      options vfio-pci disable_denylist=1 ids=${lib.concatStringsSep "," vfioIds}
    ''
    + (lib.concatMapStringsSep "\n" (n: ''
      blacklist ${n}
      install ${n} ${pkgs.coreutils}/bin/true
    '') blacklistedModules);

  systemd.services.qat-sriov = {
    description = "Enable Intel QAT SRIOV";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    requires = [ "systemd-modules-load.service" ];
    before = [
      "pve-guests.service"
      "pvedaemon.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "3";
    };
    script = ''
      DEVICE_PATH=/sys/devices/pci0000:00/0000:00:06.0/0000:01:00.0
      NUMVFS=$(cat "$DEVICE_PATH/sriov_totalvfs")
      echo 0 > "$DEVICE_PATH/sriov_drivers_autoprobe"
      echo "$NUMVFS" > "$DEVICE_PATH/sriov_numvfs"

      ${pkgs.kmod}/bin/modprobe -v vfio-pci

      for VF in $DEVICE_PATH/virtfn*; do
        PCI_ADDR=$(readlink -f $VF)
        PCI_ADDR=''${PCI_ADDR##*/}

        if [ "$(basename $VF)" = "virtfn0" ]; then
          DRIVER="qat_c3xxxvf"
        else
          DRIVER="vfio-pci"
        fi

        echo "$DRIVER" > "$VF/driver_override"
        echo "$PCI_ADDR" > /sys/bus/pci/drivers_probe
      done
    '';
  };
}
