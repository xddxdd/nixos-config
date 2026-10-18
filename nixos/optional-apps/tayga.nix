{ lib, LT, ... }:
{
  services.tayga = {
    enable = true;
    ipv4 = {
      address = "192.0.2.0";
      router = {
        address = "192.0.2.1";
      };
      pool = {
        address = "192.0.2.0";
        prefixLength = 24;
      };
    };
    ipv6 = {
      address = "2001:470:e997::1";
      router = {
        address = "64:ff9b::1";
      };
      pool = {
        address = "64:ff9b::";
        prefixLength = 96;
      };
    };
  };

  # nixpkgs tayga module only uses DynamicUser; confinement chroot + user
  # namespace makes host paths nobody:nogroup (same fix as fluent-bit)
  users.users.tayga = {
    isSystemUser = true;
    group = "tayga";
  };
  users.groups.tayga = { };

  systemd.services.tayga.serviceConfig = LT.networkToolHarden // {
    RestartSec = "5s";
    DynamicUser = lib.mkForce false;
    User = "tayga";
    Group = "tayga";
    # NAT64 TUN device; tayga creates its own unix datagram socket
    PrivateDevices = false;
    PrivateUsers = lib.mkForce false;
    BindPaths = [ "/var/lib/tayga" ];
    # Config file is a symlink chain resolved outside the confinement chroot
    BindReadOnlyPaths = [
      "/etc/localtime"
      "/etc/tayga.conf"
    ];
  };

  systemd.services.tayga.confinement = { enable = true; fullUnit = true; };
}