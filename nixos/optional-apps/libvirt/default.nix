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
      # Allow access to additional devices and Venus renderer
      verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm"
        ]
        seccomp_sandbox = 0
      '';
    };
  };

  users.users.lantian.extraGroups = [ "libvirtd" ];

  # libvirt's dnsmasq serves DHCP and DNS to guests on virbr*.
  lantian.firewall.zones = {
    LAN = {
      ports."53".type = "local";
      udpPorts."67".type = "local";
    };
  };
}
