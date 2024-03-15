{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  vppStartupScript = pkgs.writeText "vpp.startup" ''
    set interface state GigabitEthernet6/13/0 up
    set dhcp client intfc GigabitEthernet6/13/0

    create sub-interface GigabitEthernet6/13/0 1
    set interface state GigabitEthernet6/13/0.1 up
    set interface ip address GigabitEthernet6/13/0.1 192.168.1.15/24
  '';

  vppConf = pkgs.writeText "vpp.conf" ''
    unix {
      nodaemon
      log /var/log/vpp/vpp.log
      full-coredump
      cli-listen /run/vpp/cli.sock
      startup-config ${vppStartupScript}
      gid vpp
    }

    plugin_path ${pkgs.vpp}/lib/vpp_plugins

    plugins {
      ## Disable all plugins, selectively enable specific plugins
      ## YMMV, you may wish to enable other plugins (acl, etc.)
      plugin default { disable }
      plugin dhcp_plugin.so { enable }
      plugin dns_plugin.so { enable }
      plugin dpdk_plugin.so { enable }
      plugin nat_plugin.so { enable }
      plugin ping_plugin.so { enable }
    }

    api-segment {
      gid vpp
    }
    dpdk {
      dev 0000:06:13.0
    }
  '';
in
{
  boot = {
    kernelModules = [ "igb_uio" ];
    extraModulePackages = with config.boot.kernelPackages; [ dpdk-kmod ];
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "amd_iommu=on"
    ];
  };

  systemd.services.vpp = {
    description = "Vector Packet Processing Process";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      which
      iproute2
    ];
    serviceConfig = {
      ExecStartPre = [
        "-${pkgs.coreutils}/bin/rm -f /dev/shm/db /dev/shm/global_vm /dev/shm/vpe-api"
        "${pkgs.kmod}/bin/modprobe -v igb_uio"
        "${pkgs.dpdk}/bin/dpdk-devbind.py -b igb_uio 0000:06:13.0"
      ];
      ExecStart = "${pkgs.vpp}/bin/vpp -c ${vppConf}";
      ExecStopPost = "${pkgs.dpdk}/bin/dpdk-devbind.py -u 0000:06:13.0";

      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  environment.systemPackages = with pkgs; [ vpp ];

  users.users.vpp = {
    group = "vpp";
    isSystemUser = true;
  };
  users.groups.vpp = { };
}
