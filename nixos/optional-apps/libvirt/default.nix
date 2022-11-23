{ pkgs, lib, config, utils, inputs, ... }@args:

{
  environment.etc."ssdt1.dat".source = ./ssdt1.dat;

  security.polkit.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      ovmf.enable = true;
      swtpm.enable = true;
      verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm",
          "/dev/kvmfr0"
        ]
      '';
    };
  };

  users.users.lantian.extraGroups = [ "libvirtd" ];

  boot.kernelParams =
    (lib.optionals config.hardware.cpu.intel.updateMicrocode [ "intel_iommu=on" "iommu=pt" ])
    ++ (lib.optionals config.hardware.cpu.amd.updateMicrocode [ "amd_iommu=on" ]);
}
