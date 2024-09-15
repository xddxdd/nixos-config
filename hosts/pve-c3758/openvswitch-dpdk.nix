{
  pkgs,
  lib,
  config,
  ...
}:
let
  interfaces = {
    "dpdk-04000" = "0000:04:00.0";
    "dpdk-05000" = "0000:05:00.0";
    "dpdk-06000" = "0000:06:00.0";
    "dpdk-07000" = "0000:07:00.0";
    "dpdk-08000" = "0000:08:00.0";
    "dpdk-0b000" = "0000:0b:00.0";
    "dpdk-0b001" = "0000:0b:00.1";
    "dpdk-0d000" = "0000:0d:00.0";
    "dpdk-0d001" = "0000:0d:00.1";
  };
in
{
  boot.kernelParams = [
    "default_hugepagesz=1G"
    "hugepagesz=1G"
    "hugepages=30"
  ];

  virtualisation.vswitch = {
    enable = true;
    package = pkgs.openvswitch-dpdk;
  };
  environment.persistence."/nix/persistent".directories = [ "/var/db/openvswitch" ];

  systemd.services.ovsdb-setup = {
    description = "Setup OpenVSwitch database";
    wantedBy = [ "multi-user.target" ];
    after = [ "ovs-vswitchd.service" ];
    requires = [ "ovs-vswitchd.service" ];

    serviceConfig.Type = "oneshot";

    path = [ config.virtualisation.vswitch.package ];

    script =
      ''
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-init=true"
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-lcore-mask=0x80"
        ovs-vsctl set Open_vSwitch . "other_config:pmd-cpu-mask=0x80"
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-socket-mem=2048"
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-socket-limit=2048"
        ovs-vsctl set Open_vSwitch . "other_config:vhost-iommu-support=true"
        ovs-vsctl set Open_vSwitch . "other_config:pmd-auto-lb=true"

        # Allow list for DPDK interfaces
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-extra=${
          builtins.concatStringsSep " " (lib.mapAttrsToList (_n: v: "-a ${v}") interfaces)
        }"

        ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev || true
        ovs-vsctl set Bridge br0 rstp_enable=true || true
      ''
      + (builtins.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: ''
          ovs-vsctl add-port br0 ${n} || true
          ovs-vsctl set Interface ${n} type=dpdk \
            options:dpdk-devargs=${v} \
            mtu_request=9000 \
            options:n_rxq=4 \
            || true
        '') interfaces
      ))
      + (lib.concatMapStringsSep "\n" (i: ''
        ovs-vsctl add-port br0 vhost${i} || true
        ovs-vsctl set Interface vhost${i} \
          type=dpdkvhostuserclient \
          options:vhost-server-path=/run/ovs-vhost${i}.sock \
          mtu_request=9000 \
          || true
      '') (builtins.map builtins.toString (lib.range 0 9)))
      + ''
        ovs-vsctl set port dpdk-08000 tag=201 || true
      '';
  };

  systemd.services.ovs-vswitchd = {
    path = with pkgs; [
      dpdk
      which
      pciutils
      iproute2
    ];

    preStart = builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (_n: v: "dpdk-devbind.py -b vfio-pci ${v}") interfaces
    );
  };
}
