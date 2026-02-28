{ pkgs, lib, ... }:
{
  # VLAN netdevs
  systemd.network.netdevs = {
    # VLAN for homelab hosts
    "eth0.1" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "eth0.1";
      };
      vlanConfig.Id = 1;
    };

    # VLAN for Sophos Firewall (deprecated)
    "eth0.2" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "eth0.2";
      };
      vlanConfig.Id = 2;
    };

    # VLAN for IoT devices
    "eth0.5" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "eth0.5";
      };
      vlanConfig.Id = 5;
    };

    # VLAN for WAN
    "eth1.201" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "eth1.201";
      };
      vlanConfig.Id = 201;
    };

    # Bridge for WAN to access ONT WebUI
    eth1-br = {
      netdevConfig = {
        Kind = "bridge";
        Name = "eth1-br";
      };
    };
  };

  systemd.network.networks = {
    # Parent interface for VLANs
    eth0 = {
      matchConfig.Name = "eth0";
      networkConfig.VLAN = [
        "eth0.1"
        "eth0.2"
        "eth0.5"
      ];
      address = [
        "192.168.0.1/24"
        "2001:470:e997::1/64"
        "fc00:192:168::1/64"
      ];
      routes = [
        {
          # LTE IPs for lt-home-lte
          Destination = "192.168.4.0/24";
          Gateway = "192.168.0.9";
        }
        {
          # LTE IPs for lt-home-lte
          Destination = "2001:470:e997:4000::/52";
          Gateway = "fc00:192:168::9";
        }
      ];
      networkConfig.IPv6SendRA = "yes";
      ipv6SendRAConfig = {
        EmitDNS = true;
        DNS = "2001:470:e997::1";
        Managed = true;
        OtherInformation = true;
      };
      ipv6Prefixes = [ { Prefix = "2001:470:e997::/64"; } ];
    };

    # VLAN interfaces with static IPs
    "eth0.1" = {
      matchConfig.Name = "eth0.1";
      address = [
        "192.168.1.1/24"
        "2001:470:e997:1::1/64"
        "fc00:192:168:1::1/64"
      ];
      networkConfig.IPv6SendRA = "yes";
      ipv6SendRAConfig = {
        EmitDNS = true;
        DNS = "2001:470:e997:1::1";
        Managed = true;
        OtherInformation = true;
      };
      ipv6Prefixes = [ { Prefix = "2001:470:e997:1::/64"; } ];
    };
    "eth0.2" = {
      matchConfig.Name = "eth0.2";
      address = [
        "192.168.2.254/24"
        "2001:470:e997:2::254/64"
        "fc00:192:168:2::254/64"
      ];
    };
    "eth0.5" = {
      matchConfig.Name = "eth0.5";
      address = [
        "192.168.5.1/24"
        "2001:470:e997:5::1/64"
        "fc00:192:168:5::1/64"
      ];
      networkConfig.IPv6SendRA = "yes";
      ipv6SendRAConfig = {
        EmitDNS = true;
        DNS = "2001:470:e997:5::1";
        Managed = true;
        OtherInformation = true;
      };
      ipv6Prefixes = [ { Prefix = "2001:470:e997:5::/64"; } ];
    };

    # WAN interface
    eth1 = {
      matchConfig.Name = "eth1";
      networkConfig = {
        Bridge = [ "eth1-br" ];
        VLAN = [ "eth1.201" ];
      };
    };

    "eth1.201" = {
      matchConfig.Name = "eth1.201";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = "no";
      };
      cakeConfig = {
        Bandwidth = "1G";
        FlowIsolationMode = "dual-src-host";
        NAT = true;
        PriorityQueueingPreset = "diffserv8";
      };
    };

    # WAN ONT WebUI access
    eth1-br.matchConfig.Name = "eth1-br";

    # WAN IPv6 Tunnel
    henet.cakeConfig = {
      Bandwidth = "1G";
      FlowIsolationMode = "dual-src-host";
      NAT = true;
      PriorityQueueingPreset = "diffserv8";
    };
  };

  lantian.netns.ont-webui-proxy = {
    ipSuffix = "254";
    postStart = ''
      ip link add link eth1-br name ont-macvlan type macvlan mode bridge
      ip link set dev ont-macvlan netns ont-webui-proxy
      ip netns exec ont-webui-proxy ip link set dev ont-macvlan up
      ip netns exec ont-webui-proxy ip addr add 192.168.1.2/24 dev ont-macvlan

      ip netns exec ont-webui-proxy ${lib.getExe pkgs.nftables} -f- <<EOF
      table inet ont-webui-proxy {
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;
          fib daddr type local dnat ip to 192.168.1.1
        }

        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          oifname ont-macvlan masquerade
        }
      }
      EOF
    '';
  };

  networking.henet = {
    enable = true;
    remote = "216.218.226.238";
    addresses = [
      "2001:470:a:3af::2/64"
      "2001:470:b:3af::1/64"
      "2001:470:e997::1/48"
    ];
    gateway = "2001:470:a:3af::1";
    attachToInterface = "eth1.201";
  };
}
