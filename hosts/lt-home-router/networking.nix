_: {
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
      networkConfig.DHCP = "yes";
      cakeConfig = {
        Bandwidth = "1G";
        FlowIsolationMode = "dual-src-host";
        NAT = true;
        PriorityQueueingPreset = "diffserv8";
      };
    };

    # WAN IPv6 Tunnel
    henet.cakeConfig = {
      Bandwidth = "1G";
      FlowIsolationMode = "dual-src-host";
      NAT = true;
      PriorityQueueingPreset = "diffserv8";
    };
  };

  networking.henet = {
    enable = true;
    remote = "216.218.226.238";
    addresses = [
      "2001:470:a:3af::2/64"
      "2001:470:b:3af::1/64"
      "2001:470:e997::1/48"
    ];
    sourceSpecificRoutes = [
      "2001:470:a:3af::/64"
      "2001:470:b:3af::/64"
      "2001:470:e997::/48"
    ];
    gateway = "2001:470:a:3af::1";
    attachToInterface = "eth1";
  };
}
