{
  pkgs,
  lib,
  config,
  ...
}:
let
  interfaces = [
    "enp65s0f0"
    "enp65s0f1"
    "enp194s0"
    "enp194s0d1"
  ];
in
{
  virtualisation.vswitch.enable = true;

  systemd.services.ovsdb-setup = {
    description = "Setup OpenVSwitch database";
    wantedBy = [ "multi-user.target" ];
    after = [ "ovs-vswitchd.service" ];
    requires = [ "ovs-vswitchd.service" ];

    serviceConfig.Type = "oneshot";

    path = [
      config.virtualisation.vswitch.package
      pkgs.iproute2
    ];

    script =
      ''
        ovs-vsctl add-br br0 || true
        ovs-vsctl set Bridge br0 rstp_enable=true || true
      ''
      + (lib.concatMapStringsSep "\n" (n: ''
        ip link set ${n} up
        ovs-vsctl add-port br0 ${n} || true
        ovs-vsctl set Interface ${n} mtu_request=9000 || true
      '') interfaces);
  };
}
