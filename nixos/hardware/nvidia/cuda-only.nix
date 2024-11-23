{ pkgs, config, ... }:
let
  nvidia_x11 = config.hardware.nvidia.package;

  nvidiaSwitchVFIOScript = pkgs.writeShellScriptBin "nvidia-switch-vfio" ''
    PCI_ADDR=0000:01:00.0
    PCI_DEVICE=$(cat /sys/bus/pci/devices/''${PCI_ADDR}/device | cut -d'x' -f2)
    PCI_VENDOR=$(cat /sys/bus/pci/devices/''${PCI_ADDR}/vendor | cut -d'x' -f2)

    systemctl stop nvidia-persistenced.service
    modprobe -rv nvidia_drm
    modprobe -rv nvidia_uvm
    modprobe -rv nvidia_modeset
    modprobe -rv nvidia

    (lsmod | grep nvidia >/dev/null) && {
      echo "Failed to unload nvidia driver!"
      exit 1
    } || echo "Unload nvidia driver success!"

    sleep 1

    modprobe -v vfio-pci ids=''${PCI_VENDOR}:''${PCI_DEVICE}
    (readlink /sys/bus/pci/devices/''${PCI_ADDR}/driver | grep vfio-pci >/dev/null) || {
      echo "Failed to load vfio driver!"
      exit 1
    } && echo "Load vfio driver success!"

    exit 0
  '';

  nvidiaSwitchCUDAScript = pkgs.writeShellScriptBin "nvidia-switch-cuda" ''
    PCI_ADDR=0000:01:00.0

    modprobe -rv vfio-pci

    (lsmod | grep vfio_pci >/dev/null) && {
      echo "Failed to unload vfio driver!"
      exit 1
    } || echo "Unload vfio driver success!"

    sleep 1

    modprobe -v nvidia_uvm
    systemctl start nvidia-persistenced.service

    (readlink /sys/bus/pci/devices/''${PCI_ADDR}/driver | grep nvidia >/dev/null) || {
      echo "Failed to load nvidia driver!"
      exit 1
    } && echo "Load nvidia driver success!"

    exit 0
  '';
in
{
  services.xserver.drivers = [
    {
      name = "modesetting";
      display = true;
      deviceSection = ''
        BusID "PCI:0:2:0"
      '';
    }
  ];

  environment.systemPackages = [
    nvidia_x11.bin

    # nvidia-settings doesn't work with clang lto
    # nvidia_x11.settings

    nvidia_x11.persistenced

    nvidiaSwitchVFIOScript
    nvidiaSwitchCUDAScript

    pkgs.nvtopPackages.full
  ];

  # Enable CUDA
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ nvidia_x11.out ];
  hardware.graphics.extraPackages32 = [ nvidia_x11.lib32 ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidia_x11_beta;
  hardware.nvidia.open = false;

  # systemd.packages = [ nvidia_x11.out ];

  systemd.services = {
    "nvidia-persistenced" = {
      description = "NVIDIA Persistence Daemon";
      wantedBy = [ "multi-user.target" ];
      unitConfig.ConditionPathExists = "/dev/nvidia0";
      serviceConfig = {
        Type = "forking";
        Restart = "always";
        PIDFile = "/var/run/nvidia-persistenced/nvidia-persistenced.pid";
        ExecStart = "${nvidia_x11.persistenced}/bin/nvidia-persistenced --verbose";
        ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-persistenced";
      };
    };
  };

  boot.extraModulePackages = [ nvidia_x11.bin ];

  # nvidia-uvm is required by CUDA applications.
  boot.kernelModules = [ "nvidia-uvm" ];

  services.udev.extraRules = ''
    # Create /dev/nvidia-uvm when the nvidia-uvm module is loaded.
    KERNEL=="nvidia", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidiactl c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 255'"
    KERNEL=="nvidia_modeset", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-modeset c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 254'"
    KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="nvidia", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia%n c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) %n'"
    KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
    KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm-tools c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"

    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
    # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
    # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
  '';

  boot.extraModprobeConfig = ''
    options nvidia "NVreg_DynamicPowerManagement=0x02"
  '';

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
    "nvidia"
    "nvidia-drm"
    "nvidia-modeset"
  ];

  services.acpid.enable = true;

  virtualisation.docker.enableNvidia = true;
  hardware.nvidia-container-toolkit.enable = true;
}
