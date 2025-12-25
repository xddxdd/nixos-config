{ ... }:
{
  imports = [ ../../hardware/vfio.nix ];

  environment.etc."ssdt1.dat".source = ./ssdt1.dat;

  security.polkit.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
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
}
