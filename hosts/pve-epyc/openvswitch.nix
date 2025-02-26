{
  pkgs,
  lib,
  config,
  LT,
  ...
}:
let
  interfaces = [
    "eno1"
    "eno2"
    "enp65s0"
    "enp65s0d1"
  ];
in
{
  virtualisation.vswitch.enable = true;
  preservation.preserveAt."/nix/persistent".directories = builtins.map LT.preservation.mkFolder [
    "/var/db/openvswitch"
  ];

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
