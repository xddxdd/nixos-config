{
  pkgs,
  lib,
  config,
  ...
}:
let
  interfaces = {
    "enp4s0" = "";
    "enp5s0" = "";
    "enp6s0" = "";
    "enp7s0" = "";
    "enp8s0" = "tag=201";
    "eno1" = "";
    "eno2" = "";
    "eno3" = "";
    "eno4" = "";
  };
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
        ovs-vsctl add-port br0 ${n} ${interfaces.${n}} || true
        ovs-vsctl set Interface ${n} mtu_request=9000 || true
      '') (builtins.attrNames interfaces));
  };
}
