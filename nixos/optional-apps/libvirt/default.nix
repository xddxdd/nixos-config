{ pkgs, lib, config, ... }:

{
  environment.etc."ssdt1.dat".source = ./ssdt1.dat;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.callPackage ./qemu {
        inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices Cocoa Hypervisor;
        inherit (pkgs.darwin.stubs) rez setfile;
        inherit (pkgs.darwin) sigtool;
      };

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
