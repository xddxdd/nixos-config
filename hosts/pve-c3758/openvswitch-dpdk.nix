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
  virtualisation.vswitch = {
    enable = true;
    package = pkgs.nur-xddxdd.openvswitch-dpdk;
  };

  systemd.services.ovs-dpdk-setup = {
    description = "Setup OpenVSwitch DPDK config";
    wantedBy = [ "multi-user.target" ];
    after = [ "ovs-vswitchd.service" ];
    requires = [ "ovs-vswitchd.service" ];

    serviceConfig.Type = "oneshot";

    path = [ config.virtualisation.vswitch.package ];

    script =
      ''
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-init=true"
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-lcore-mask=0xc0"
        ovs-vsctl set Open_vSwitch . "other_config:pmd-cpu-mask=0xc0"
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-socket-mem=2048"
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-socket-limit=2048"
        ovs-vsctl set Open_vSwitch . "other_config:vhost-iommu-support=true"
        ovs-vsctl set Open_vSwitch . "other_config:pmd-auto-lb=true"
        ovs-vsctl set Open_vSwitch . "other_config:tx-flush-interval=50"

        # Allow list for DPDK interfaces
        ovs-vsctl set Open_vSwitch . "other_config:dpdk-extra=${
          builtins.concatStringsSep " " (lib.mapAttrsToList (n: v: "-a ${v}") interfaces)
        }"

        ovs-vsctl --may-exist add-br br0 -- set bridge br0 datapath_type=netdev || true
        ovs-vsctl set Bridge br0 rstp_enable=true || true
      ''
      + (builtins.concatStringsSep "\n" (
        lib.mapAttrsToList (
          n: v:
          (
            if n == "dpdk-08000" then
              ''
                ovs-vsctl --may-exist add-port br0 ${n} tag=201 || true
                ovs-vsctl set port dpdk-08000 tag=201 || true
              ''
            else
              ''
                ovs-vsctl --may-exist add-port br0 ${n} || true
              ''
          )
          + ''
            ovs-vsctl set Interface ${n} type=dpdk \
              options:dpdk-devargs=${v} \
              mtu_request=9000 \
              options:n_rxq=4 \
              options:rx-steering=rss+lacp \
              || true
          ''
        ) interfaces
      ))
      + (lib.concatMapStringsSep "\n" (i: ''
        ovs-vsctl --may-exist add-port br0 vhost${i} || true
        ovs-vsctl set Interface vhost${i} \
          type=dpdkvhostuserclient \
          options:vhost-server-path=/run/ovs-vhost${i}.sock \
          mtu_request=9000 \
          || true
      '') (builtins.map builtins.toString (lib.range 0 9)))
      + ''
        ovs-vsctl --may-exist add-port br0 vhost4-2 tag=4 || true
        ovs-vsctl set port vhost4-2 tag=4 || true
        ovs-vsctl set Interface vhost4-2 \
          type=dpdkvhostuserclient \
          options:vhost-server-path=/run/ovs-vhost4-2.sock \
          mtu_request=9000 \
          || true
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
      lib.mapAttrsToList (n: v: ''
        if lspci -s ${v} | grep Mellanox; then
          echo "Do not bind vfio-pci driver for Mellanox NICs"
        else
          dpdk-devbind.py -b vfio-pci ${v}
        fi
      '') interfaces
    );
  };
}
